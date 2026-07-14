"""Comparison core: actual tree (from detection) vs. target tree.

Pure logic, no I/O - the single source of truth both outputs are
derived from (LED feedback frame and evaluated tree for visualization).

Every slot of the merged actual/target structure gets one status:

  CORRECT     cube present, type/parent/port/orientation all match
  WRONG       cube present but something is off (see error_mask)
  ATTACHABLE  target slot empty, parent placed and correct -> "build here next"
  BLOCKED     target slot empty, but its parent is missing/wrong too
  UNEXPECTED  cube present where the target has no slot at all

Missing cubes are never errors: the user builds step by step.

Structural rule (doc/feedback.txt): when a parent is wrong, the path of
every descendant is invalid, so present descendants are WRONG with
ERR_PARENT set (their own type/orientation checks still run so the
visualization can show all problems at once).

Wrong-port detection: a cube sitting on a port without a target slot,
while an empty sibling slot of the same cube type exists on the same
parent, is a port error (ERR_PORT) instead of UNEXPECTED - the cube
just has to move, not disappear.
"""
from dataclasses import dataclass, field
from enum import Enum
from typing import Optional

from cube_node import CubeNode
from target_tree import TargetNode, node_type

# error mask bits (doc/feedback.txt)
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


@dataclass
class CompareEntry:
    """One slot of the compare result tree.

    node_id/orientation are None for empty target slots (ghosts);
    expected_type/expected_orientation are None for UNEXPECTED cubes.
    """
    status: NodeStatus
    error_mask: int = 0
    node_id: Optional[int] = None
    orientation: Optional[int] = None
    port: Optional[int] = None
    expected_type: Optional[int] = None
    expected_orientation: Optional[int] = None
    children: list["CompareEntry"] = field(default_factory=list)


def compare(actual: Optional[CubeNode], target: TargetNode) -> CompareEntry:
    """Compare the detected tree against the target construction.

    actual may be None (nothing built yet) -> the root slot is ATTACHABLE.
    The baseplate itself counts as a present, correct parent.
    """
    return _compare_slot(actual, target, port=None, parent_status=NodeStatus.CORRECT)


def iter_entries(entry: CompareEntry):
    """Depth-first iteration over all entries of a compare result."""
    yield entry
    for child in entry.children:
        yield from iter_entries(child)


# ----------------------------------------------------------------
# internals
# ----------------------------------------------------------------

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

    # wrong-port heuristic: cubes without a target slot vs. empty
    # sibling slots of the same type on this parent
    empty_slot_types = [
        target.children[p].cube_type
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

        if misplaced_type in empty_slot_types:
            empty_slot_types.remove(misplaced_type)  # each empty slot excuses one cube
            entries.append(_misplaced(actual_child, p, own_status))
        else:
            entries.append(_unexpected(actual_child, p))

    return entries


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
    )

    # everything below an empty slot can only be built later
    for child_port in sorted(target.children):
        entry.children.append(
            _missing_slot(target.children[child_port], child_port, status)
        )

    return entry


def _misplaced(actual: CubeNode, port: int, parent_status: NodeStatus) -> CompareEntry:
    """Right cube type on the right parent, but on the wrong port."""
    mask = ERR_PORT

    if parent_status is not NodeStatus.CORRECT:
        mask |= ERR_PARENT

    entry = CompareEntry(
        status=NodeStatus.WRONG,
        error_mask=mask,
        node_id=actual.id,
        orientation=actual.orientation,
        port=port,
    )

    # descendants have no valid path as long as this cube sits wrong
    for child in actual.children:
        entry.children.append(_invalid_path(child))

    return entry


def _invalid_path(actual: CubeNode) -> CompareEntry:
    """Present cube whose whole path is invalid (no target to compare against)."""
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


def _unexpected(actual: CubeNode, port: Optional[int]) -> CompareEntry:
    """Cube where the target has no slot; its whole subtree is unexpected."""
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
