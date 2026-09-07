"""
compare_core.py
- compares the detected tree (CubeNode) against the selected target
  (TargetNode) and produces one CompareEntry per slot
- every slot gets one status:
    CORRECT     cube present, type/parent/port/orientation all match
    WRONG       cube present but something is off (see error_mask)
    ATTACHABLE  target slot empty, parent placed and correct -> "build here next"
    BLOCKED     target slot empty, but its parent is missing/wrong too
    UNEXPECTED  cube present where the target has no slot at all
- wo aufgerufen?
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import Optional

from cube_node import CubeNode, node_type
from target_tree import TargetNode

# ----------------------------------------------------------
# Error mask bits
# - a CompareEntry can carry more than one of these at once 
# ----------------------------------------------------------

ERR_TYPE        = 1 << 0
ERR_PARENT      = 1 << 1
ERR_PORT        = 1 << 2
ERR_ORIENTATION = 1 << 3
ERR_UNEXPECTED  = 1 << 4

# explained in the files overview
class NodeStatus(str, Enum):
    CORRECT    = "correct"
    WRONG      = "wrong"
    ATTACHABLE = "attachable"
    BLOCKED    = "blocked"
    UNEXPECTED = "unexpected"

"""
CompareEntry
- one node of the compare result tree (cubeNode and targetNode compared with each other): 
    - the actual values (if any),
    - the expected/target values
    - the resulting status
"""
@dataclass
class CompareEntry:
    #actual values (from the detected CubeNode)
    status: NodeStatus                          # this slot's classification: CORRECT/WRONG/ATTACHABLE/BLOCKED/UNEXPECTED
    error_mask: int = 0                         # ERR_* bits OR'd together
    node_id: Optional[int] = None               # full NODE_ID of the cube physically present here; None if no cube sits at this slot
    orientation: Optional[int] = None           # actual orientation (0..3) of that cube
    port: Optional[int] = None                  # port this entry sits on under its parent; None only for the root (no parent port)

    # expected/target values
    expected_type: Optional[int] = None         # target's cube_type for this slot; None where no single target slot applies (_misplaced, _invalid_path, _unexpected)
    expected_orientation: Optional[int] = None  # target's orientation for this slot
    expected_port: Optional[int] = None         # port this cube SHOULD be at; set for matched/missing/misplaced slots, None where there is no known correct position (_invalid_path, _unexpected)

    children: list["CompareEntry"] = field(default_factory=list)  # this slot's own children

"""
compare - main function
- entry point: compares the whole detected tree against the whole target
"""
def compare(actual: Optional[CubeNode], target: TargetNode) -> CompareEntry:
    return _compare_slot(actual, target, port=None, parent_status=NodeStatus.CORRECT) # root calls starts with parent_status = correct since first brick hase baseplate as a parent -> always correct

"""
iter_entries
- depth-first walk over every entry of a compare result
- used by feedback_output.py to collect LED states without writing its own tree-walk
= Das ist ein Generator, der den ganzen CompareEntry-Baum depth-first abläuft und dabei jeden Knoten einzeln nacheinander liefert 
"""
def iter_entries(entry: CompareEntry):
    yield entry
    for child in entry.children:
        yield from iter_entries(child)


# ----------------------------------------------------------------
# internals
# ----------------------------------------------------------------


"""
_compare_slot
- compares one actual/target pair at a given port
    -> builds this node's own CompareEntry from that result, then recurses
  into _compare_children afterwards to attach its children
"""
def _compare_slot(
    actual: Optional[CubeNode],
    target: TargetNode,
    port: Optional[int],
    parent_status: NodeStatus,
) -> CompareEntry:

    if actual is None:
        return _missing_slot(target, port, parent_status)

    mask = 0

    if node_type(actual.id) != target.cube_type:
        mask |= ERR_TYPE

    if actual.orientation != target.orientation:
        mask |= ERR_ORIENTATION

    # structural rule: invalid parent path invalidates this node too
    if parent_status is not NodeStatus.CORRECT:
        mask |= ERR_PARENT

    status = NodeStatus.CORRECT if mask == 0 else NodeStatus.WRONG

    #  baut diesen einen node (aktuellen slot)
    entry = CompareEntry(
        status=status,
        error_mask=mask, # hier wird nur das verändert
        node_id=actual.id,
        orientation=actual.orientation,
        port=port,
        expected_type=target.cube_type,
        expected_orientation=target.orientation,
        expected_port=port,  # matched by port, so actual = expected
    )

    # füllt das gerade gebaute compareEntry danach mit der Kinderliste 
    entry.children = _compare_children(actual, target, status)
    return entry

"""
_compare_children
- matches actual children to target children by PORT (both are keyed by
  port), then recurses _compare_slot for every child port the target has
- for a port the target does NOT use, decides between two outcomes for
  the actual cube sitting there: "wrong port" or "truly unexpected"
  (see the wrong-port heuristic below)
"""
def _compare_children(
    actual: CubeNode,
    target: TargetNode,
    own_status: NodeStatus,
) -> list[CompareEntry]:

    actual_by_port = {child.port: child for child in actual.children}
    all_ports = sorted(set(actual_by_port) | set(target.children))

    # wrong-port heuristic:
    # a cube sitting on a port the target doesn't use is only "wrong port" (not "unexpected") if some OTHER port on this same parent
    # is a target slot of the exact same cube type with nothing physically attached there 
    #  -> that empty slot is where the cube was probably meant to go. 
    
    empty_slots = [  #collects exactly those (port, cube_type) candidates once, up front, before the port loop below can start consuming them.
        (p, target.children[p].cube_type)
        for p in target.children
        if p not in actual_by_port
    ]

    entries: list[CompareEntry] = []

    for p in all_ports:
        actual_child = actual_by_port.get(p)
        target_child = target.children.get(p)

        # normal case: this port is part of the target
        if target_child is not None:
            entries.append(_compare_slot(actual_child, target_child, p, own_status))
            continue

        # brick present on a port the target does not use at all
        misplaced_type = node_type(actual_child.id)
        matching_slot = next(
            (slot for slot in empty_slots if slot[1] == misplaced_type),
            None,
        )

        if matching_slot is not None:
            empty_slots.remove(matching_slot)  # each empty slot excuses one cube
            entries.append(
                _misplaced(actual_child, p, own_status, expected_port=matching_slot[0])
            )
        # no free slot of this type left to blame -> genuinely not part of the target at all
        else:
            entries.append(_unexpected(actual_child, p))

    return entries



# ----------------------------------------------------------------
# error functions that then determine the exact error and node status assigned to the individual node
# ----------------------------------------------------------------
"""
_missing_slot
- target expects a cube here, but nothing is physically attached at all
- status depends on wether parent is
    -> is fully correct: this exact slot is ATTACHABLE ("build here next")
    -> missing/wrong, this slot is BLOCKED (nothing to attach to yet)
- IMPORTANT: so ATTACHABLE only ever applies to the slot directly reachable from a correct parent; every target node further beneath is BLOCKED
"""
def _missing_slot(
    target: TargetNode,
    port: Optional[int],
    parent_status: NodeStatus,
) -> CompareEntry:

    if parent_status is NodeStatus.CORRECT:
        status = NodeStatus.ATTACHABLE
    else:
        status = NodeStatus.BLOCKED

    entry = CompareEntry(
        status=status, # hier wird nur das verändert
        port=port,
        expected_type=target.cube_type,
        expected_orientation=target.orientation,
        expected_port=port,  # a ghost slot's port IS the expected port
    )

    # everything below an empty slot can only be built later
    for child_port in sorted(target.children):
        entry.children.append(
            _missing_slot(target.children[child_port], child_port, status)
        )

    return entry

"""
_misplaced
- the right cube type for some empty target slot on this same parent,
  but physically attached on the wrong port
"""
def _misplaced(
    actual: CubeNode,
    port: int,
    parent_status: NodeStatus,
    expected_port: int,
) -> CompareEntry:
    mask = ERR_PORT

    if parent_status is not NodeStatus.CORRECT:
        mask |= ERR_PARENT

    entry = CompareEntry(
        status=NodeStatus.WRONG, # hier wird das verändert
        error_mask=mask,  # und das verändert
        node_id=actual.id,
        orientation=actual.orientation,
        port=port,
        expected_port=expected_port,  
    )
    # descendants have no valid path as long as this cube sits wrong
    for child in actual.children:
        entry.children.append(_invalid_path(child))

    return entry

"""
_invalid_path
- a present cube with no target counterpart to compare against at all
    -> its whole subtree (children) has an invalid_path 
"""
def _invalid_path(actual: CubeNode) -> CompareEntry:
    entry = CompareEntry(
        status=NodeStatus.WRONG, # hier wird das verändert
        error_mask=ERR_PARENT,  # und das verändert
        node_id=actual.id,
        orientation=actual.orientation,
        port=actual.port,
    )

    for child in actual.children:
        entry.children.append(_invalid_path(child))

    return entry

"""
_unexpected
- a present cube (and everything below it) that the target has no
  relationship to whatsoever
  -> its whole subtree (children) is unexpected.
"""
def _unexpected(actual: CubeNode, port: Optional[int]) -> CompareEntry:
    entry = CompareEntry(
        status=NodeStatus.UNEXPECTED, # hier wird das verändert
        error_mask=ERR_UNEXPECTED, # und das verändert
        node_id=actual.id,
        orientation=actual.orientation,
        port=port,
    )

    for child in actual.children:
        entry.children.append(_unexpected(child, child.port))

    return entry
