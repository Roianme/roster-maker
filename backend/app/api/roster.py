from fastapi import APIRouter, HTTPException
from ..models.schemas import GenerateRosterRequest, GenerateRosterResponse
from ..services.roster_solver import RosterSolver

router = APIRouter(prefix="/api/roster", tags=["roster"])


@router.post("/generate", response_model=GenerateRosterResponse)
async def generate_roster(request: GenerateRosterRequest):
    """
    Generate a weekly roster using OR-Tools CP-SAT solver.
    
    This is a POC endpoint. In production, this would:
    1. Fetch templates from Firestore for the venue
    2. Fetch staff from Firestore
    3. Fetch availability from Firestore
    4. Call the solver
    5. Return the generated roster
    """
    try:
        solver = RosterSolver()
        
        # POC: Return mock data
        # In production, fetch from Firestore based on request.venue_id
        from ..models.schemas import WeekdayTemplate, ShiftBlock, Staff, RosterShift
        
        templates = [
            WeekdayTemplate(
                id="template1",
                venue_id=request.venue_id,
                weekday=0,  # Monday
                shift_blocks=[
                    ShiftBlock(start_time="09:00", end_time="17:00", role_id="chef", count=2),
                    ShiftBlock(start_time="17:00", end_time="23:00", role_id="waiter", count=3),
                ],
            ),
        ]
        
        staff_list = [
            Staff(id="staff1", first_name="John", last_name="Doe", email="john@example.com", role_ids=["chef"]),
            Staff(id="staff2", first_name="Jane", last_name="Smith", email="jane@example.com", role_ids=["waiter"]),
        ]
        
        availability = []
        
        result = solver.generate_roster(
            venue_id=request.venue_id,
            venue_name="Demo Venue",
            week_start=request.week_start,
            templates=templates,
            staff=staff_list,
            availability=availability,
        )
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "roster-generator"}
