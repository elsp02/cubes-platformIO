""" data class for Node"""
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class CubeNode:
    cube_id: int
    orientation: int
    port: Optional[int]
    child_mask: int = 0
    children: list["CubeNode"] = field(default_factory=list)