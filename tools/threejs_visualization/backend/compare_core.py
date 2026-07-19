"""Comparison core: actual tree (from detection) vs. target tree.

Every slot of the merged actual/target structure gets one status:
  CORRECT     cube present, type/parent/port/orientation all match
  WRONG       cube present but something is off (see error_mask)
  ATTACHABLE  target slot empty, parent placed and correct -> "build here next"
  BLOCKED     target slot empty, but its parent is missing/wrong too
  UNEXPECTED  cube present where the target has no slot at all


Structural rule (doc/feedback.txt): when a parent is wrong, the path of
every descendant is invalid, so present descendants are WRONG with
ERR_PARENT set (their own type/orientation checks still run so the
visualization can show all problems at once)
"""
from dataclasses import dataclass, field
from enum import Enum
from typing import Optional

from cube_node import CubeNode, node_type
from target_tree import TargetNode

"""error mask bits (doc/feedback.txt) """
ERR_TYPE        = 1 << 0
ERR_PARENT      = 1 << 1
ERR_PORT        = 1 << 2
ERR_ORIENTATION = 1 << 3
ERR_UNEXPECTED  = 1 << 4


class NodeStatus(str, Enum):
    CORRECT    = "correct"
    WRONG      = "wrong"
    ATTACHABLE = "attachable"
    BLOCKED    = "blocked"
    UNEXPECTED = "unexpected"

"""One Node of the compare result tree"""
@dataclass
class CompareEntry:
    #actual values
    status: NodeStatus
    error_mask: int = 0
    node_id: Optional[int] = None
    orientation: Optional[int] = None
    port: Optional[int] = None
    #exptected/target values
    expected_type: Optional[int] = None
    expected_orientation: Optional[int] = None
    expected_port: Optional[int] = None
    children: list["CompareEntry"] = field(default_factory=list)

"""Compare the detected tree against the target construction.
baseplate itself counts as a present, correct parent.
"""
#main function
def compare(actual: Optional[CubeNode], target: TargetNode) -> CompareEntry:
    return _compare_slot(actual, target, port=None, parent_status=NodeStatus.CORRECT)

"""Depth-first iteration over all entries of a compare result."""
def iter_entries(entry: CompareEntry):
    yield entry
    for child in entry.children:
        yield from iter_entries(child)


# ----------------------------------------------------------------
# internals
# ----------------------------------------------------------------

#function who describes error mask
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

    entry = CompareEntry(
        status=status,
        error_mask=mask,
        node_id=actual.id,
        orientation=actual.orientation,
        port=port,
        expected_type=target.cube_type,
        expected_orientation=target.orientation,
        expected_port=port,  # matched by port, so actual = expected
    )

    entry.children = _compare_children(actual, target, status)
    return entry


def _compare_children(
    actual: CubeNode,
    target: TargetNode,
    own_status: NodeStatus,
) -> list[CompareEntry]:

    actual_by_port = {child.port: child for child in actual.children}
    all_ports = sorted(set(actual_by_port) | set(target.children))

    # wrong-port heuristic: cubes without a target slot vs. empty sibling slots of the same type on this parent; 
    # the port is kept so a misplaced cube knows WHERE it should move (expected_port)
    empty_slots = [
        (p, target.children[p].cube_type)
        for p in target.children
        if p not in actual_by_port
    ]

    entries: list[CompareEntry] = []

    for p in all_ports:
        actual_child = actual_by_port.get(p)
        target_child = target.children.get(p)

        if target_child is not None:
            entries.append(_compare_slot(actual_child, target_child, p, own_status))
            continue

        # cube present on a port the target does not use
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
        else:
            entries.append(_unexpected(actual_child, p))

    return entries

# below: error functions that then determine the exact error and node status assigned to the individual node
"""if target expects a cube at this port but there is physically nothing attached"""
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
        status=status,
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

"""Right cube type on the right parent, but on the wrong port."""
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
        status=NodeStatus.WRONG,
        error_mask=mask,
        node_id=actual.id,
        orientation=actual.orientation,
        port=port,
        expected_port=expected_port,  
    )
    # descendants have no valid path as long as this cube sits wrong
    for child in actual.children:
        entry.children.append(_invalid_path(child))

    return entry

"""Present cube whose whole path is invalid (no target to compare against)."""
def _invalid_path(actual: CubeNode) -> CompareEntry:
    entry = CompareEntry(
        status=NodeStatus.WRONG,
        error_mask=ERR_PARENT,
        node_id=actual.id,
        orientation=actual.orientation,
        port=actual.port,
    )

    for child in actual.children:
        entry.children.append(_invalid_path(child))

    return entry

"""Cube where the target has no slot -> its whole subtree is unexpected."""
def _unexpected(actual: CubeNode, port: Optional[int]) -> CompareEntry:
    entry = CompareEntry(
        status=NodeStatus.UNEXPECTED,
        error_mask=ERR_UNEXPECTED,
        node_id=actual.id,
        orientation=actual.orientation,
        port=port,
    )

    for child in actual.children:
        entry.children.append(_unexpected(child, child.port))

    return entry
