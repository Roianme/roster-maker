from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class ShiftBlock(BaseModel):
    start_time: str  # HH:mm format
    end_time: str
    role_id: str
    count: int


class WeekdayTemplate(BaseModel):
    id: str
    venue_id: str
    weekday: int  # 0 = Monday, 6 = Sunday
    shift_blocks: List[ShiftBlock]
    supervisor_role_id: Optional[str] = None


class Staff(BaseModel):
    id: str
    first_name: str
    last_name: str
    email: str
    role_ids: List[str]
    active: bool = True


class Availability(BaseModel):
    staff_id: str
    weekday: int
    available: bool


class GenerateRosterRequest(BaseModel):
    venue_id: str
    week_start: datetime
    locked_shift_ids: List[str] = []


class RosterShift(BaseModel):
    slot_id: str
    venue_id: str
    venue_name: str
    date: str
    start_time: str
    end_time: str
    role_id: str
    role_name: str
    employee_id: Optional[str] = None
    employee_name: Optional[str] = None
    locked: bool = False


class GenerateRosterResponse(BaseModel):
    shifts: List[RosterShift]
    warnings: List[str] = []
    reasons: dict = {}
