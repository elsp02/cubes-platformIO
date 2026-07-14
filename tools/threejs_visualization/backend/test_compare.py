"""Scenario tests for the comparison core.

Every scenario runs the full pipeline:
fixture tree -> serialize_tree -> parse_tree -> compare -> outputs

Run with:  python -m pytest test_compare.py -v
or plain:  python test_compare.py
"""
from cube_node import CubeNode
from payload_parser import parse_tree, serialize_tree
from target_tree import TARGET_TOWER_3
from compare_core import (
    compare,
    iter_entries,
    NodeStatus,
    ERR_TYPE,
    ERR_PARENT,
    ERR_PORT,
    ERR_ORIENTATION,
    ERR_UNEXPECTED,
)
from feedback_output import (
    led_states,
    build_feedback_frame,
    build_evaluated_tree,
    LED_GREEN,
    LED_RED,
)

CUBE_A = 0x10  # instance IDs of the prototype cubes (all type 0)
CUBE_B = 0x11
CUBE_C = 0x12
CUBE_D = 0x13
CUBE_TYPE1 = 0x30  # a type-1 cube (0x30 >> 5 == 1)


# ----------------------------------------------------------------
# fixture helpers
# ----------------------------------------------------------------

def make_node(node_id: int, orientation: int = 0, children: dict[int, CubeNode] | None = None) -> CubeNode:
    """Build a CubeNode with child_mask/ports derived from the children dict."""
    children = children or {}
    child_mask = 0
    child_list = []

    for port in sorted(children):
        child_mask |= 1 << port
        children[port].port = port
        child_list.append(children[port])

    return CubeNode(
        id=node_id,
        orientation=orientation,
        port=None,
        child_mask=child_mask,
        children=child_list,
    )


def perfect_tower() -> CubeNode:
    """A - B - C chained on port 0, all orientation 0 (matches TARGET_TOWER_3)."""
    return make_node(CUBE_A, 0, {
        0: make_node(CUBE_B, 0, {
            0: make_node(CUBE_C, 0),
        }),
    })


def run_compare(actual: CubeNode | None):
    """Full pipeline: (re)serialize + parse the fixture, then compare."""
    if actual is not None:
        actual = parse_tree(serialize_tree(actual))
    return compare(actual, TARGET_TOWER_3)


def statuses(result) -> list[NodeStatus]:
    return [entry.status for entry in iter_entries(result)]


def find(result, node_id):
    """First entry with the given node_id (or expected ghost when node_id None)."""
    for entry in iter_entries(result):
        if entry.node_id == node_id:
            return entry
    raise AssertionError(f"No entry with node_id {node_id!r}")


def ghosts(result) -> list:
    """All empty-slot entries (attachable/blocked)."""
    return [e for e in iter_entries(result) if e.node_id is None]


# ----------------------------------------------------------------
# 1. round-trip
# ----------------------------------------------------------------

def test_serialize_parse_roundtrip():
    tree = perfect_tower()
    payload = serialize_tree(tree)

    assert payload == bytes([
        CUBE_A, 0, 0x01,
        CUBE_B, 0, 0x01,
        CUBE_C, 0, 0x00,
    ])
    assert parse_tree(payload) == tree


# ----------------------------------------------------------------
# 2. perfect match
# ----------------------------------------------------------------

def test_perfect_match():
    result = run_compare(perfect_tower())

    assert statuses(result) == [NodeStatus.CORRECT] * 3
    assert all(entry.error_mask == 0 for entry in iter_entries(result))

    entries = led_states(result)
    assert entries == [(CUBE_A, LED_GREEN), (CUBE_B, LED_GREEN), (CUBE_C, LED_GREEN)]

    # exact frame bytes lock the format against the firmware side
    frame = build_feedback_frame(entries)
    assert frame == bytes([
        0xA5,               # SYNC
        0x06,               # LEN
        CUBE_A, LED_GREEN,
        CUBE_B, LED_GREEN,
        CUBE_C, LED_GREEN,
        0x14,               # XOR checksum over LEN + payload
    ])


# ----------------------------------------------------------------
# 3. single-error scenarios
# ----------------------------------------------------------------

def test_wrong_orientation():
    actual = make_node(CUBE_A, 0, {
        0: make_node(CUBE_B, 2, {          # orientation 2 instead of 0
            0: make_node(CUBE_C, 0),
        }),
    })
    result = run_compare(actual)

    assert find(result, CUBE_A).status is NodeStatus.CORRECT
    b = find(result, CUBE_B)
    assert b.status is NodeStatus.WRONG
    assert b.error_mask == ERR_ORIENTATION

    # structural rule: C itself matches, but its path is invalid
    c = find(result, CUBE_C)
    assert c.status is NodeStatus.WRONG
    assert c.error_mask == ERR_PARENT

    assert led_states(result) == [
        (CUBE_A, LED_GREEN), (CUBE_B, LED_RED), (CUBE_C, LED_RED),
    ]


def test_wrong_type():
    actual = make_node(CUBE_A, 0, {
        0: make_node(CUBE_TYPE1, 0, {      # type 1 where type 0 is expected
            0: make_node(CUBE_C, 0),
        }),
    })
    result = run_compare(actual)

    wrong = find(result, CUBE_TYPE1)
    assert wrong.status is NodeStatus.WRONG
    assert wrong.error_mask == ERR_TYPE
    assert find(result, CUBE_C).error_mask == ERR_PARENT


def test_wrong_port():
    actual = make_node(CUBE_A, 0, {
        1: make_node(CUBE_B, 0, {          # port 1 instead of port 0
            0: make_node(CUBE_C, 0),
        }),
    })
    result = run_compare(actual)

    b = find(result, CUBE_B)
    assert b.status is NodeStatus.WRONG
    assert b.error_mask == ERR_PORT
    assert b.port == 1

    # C hangs below a misplaced cube -> invalid path
    assert find(result, CUBE_C).error_mask == ERR_PARENT

    # the empty port-0 slot is shown as the place to build
    ghost_states = [g.status for g in ghosts(result)]
    assert NodeStatus.ATTACHABLE in ghost_states


# ----------------------------------------------------------------
# 4./5. missing cubes are not errors
# ----------------------------------------------------------------

def test_missing_cube_is_attachable():
    actual = make_node(CUBE_A, 0, {
        0: make_node(CUBE_B, 0),           # C not placed yet
    })
    result = run_compare(actual)

    assert find(result, CUBE_A).status is NodeStatus.CORRECT
    assert find(result, CUBE_B).status is NodeStatus.CORRECT

    slot_c = ghosts(result)[0]
    assert slot_c.status is NodeStatus.ATTACHABLE
    assert slot_c.error_mask == 0

    # missing cube appears in the evaluated tree but not in the frame
    assert led_states(result) == [(CUBE_A, LED_GREEN), (CUBE_B, LED_GREEN)]
    evaluated = build_evaluated_tree(result)
    assert evaluated["children"][0]["children"][0]["status"] == "attachable"


def test_missing_chain_attachable_then_blocked():
    actual = make_node(CUBE_A, 0)          # only the first cube placed
    result = run_compare(actual)

    slot_b, slot_c = ghosts(result)
    assert slot_b.status is NodeStatus.ATTACHABLE   # parent A is correct
    assert slot_c.status is NodeStatus.BLOCKED      # parent B still missing


def test_missing_slot_under_wrong_parent_is_blocked():
    actual = make_node(CUBE_A, 1)          # A present but wrong orientation
    result = run_compare(actual)

    assert find(result, CUBE_A).status is NodeStatus.WRONG
    assert all(g.status is NodeStatus.BLOCKED for g in ghosts(result))


# ----------------------------------------------------------------
# 6. extra cube
# ----------------------------------------------------------------

def test_extra_cube_is_unexpected():
    actual = make_node(CUBE_A, 0, {
        0: make_node(CUBE_B, 0, {
            0: make_node(CUBE_C, 0, {
                0: make_node(CUBE_D, 0),   # target tower ends at C
            }),
        }),
    })
    result = run_compare(actual)

    extra = find(result, CUBE_D)
    assert extra.status is NodeStatus.UNEXPECTED
    assert extra.error_mask == ERR_UNEXPECTED
    assert (CUBE_D, LED_RED) in led_states(result)


# ----------------------------------------------------------------
# 7. structural rule over a whole subtree
# ----------------------------------------------------------------

def test_wrong_parent_invalidates_descendants():
    actual = make_node(CUBE_A, 3, {        # root wrong -> everything below wrong
        0: make_node(CUBE_B, 0, {
            0: make_node(CUBE_C, 0),
        }),
    })
    result = run_compare(actual)

    assert find(result, CUBE_A).error_mask == ERR_ORIENTATION
    assert find(result, CUBE_B).error_mask == ERR_PARENT
    assert find(result, CUBE_C).error_mask == ERR_PARENT
    assert statuses(result) == [NodeStatus.WRONG] * 3
    assert all(led == LED_RED for _, led in led_states(result))


# ----------------------------------------------------------------
# 8. empty actual tree
# ----------------------------------------------------------------

def test_empty_actual_tree():
    result = run_compare(None)

    root = result
    assert root.status is NodeStatus.ATTACHABLE     # baseplate counts as correct parent
    assert [e.status for e in iter_entries(result)] == [
        NodeStatus.ATTACHABLE, NodeStatus.BLOCKED, NodeStatus.BLOCKED,
    ]

    entries = led_states(result)
    assert entries == []
    assert build_feedback_frame(entries) == bytes([0xA5, 0x00, 0x00])


# ----------------------------------------------------------------
# plain-python runner (no pytest required)
# ----------------------------------------------------------------

if __name__ == "__main__":
    import sys
    import traceback

    failed = 0
    tests = [obj for name, obj in sorted(globals().items())
             if name.startswith("test_") and callable(obj)]

    for test in tests:
        try:
            test()
            print(f"PASS  {test.__name__}")
        except Exception:
            failed += 1
            print(f"FAIL  {test.__name__}")
            traceback.print_exc()

    print(f"\n{len(tests) - failed}/{len(tests)} tests passed")
    sys.exit(1 if failed else 0)
