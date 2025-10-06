"""
Governance API endpoints
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

router = APIRouter(prefix="/api/governance", tags=["governance"])


class ProposalCreate(BaseModel):
    title: str
    description: str
    actions: List[str]


class Proposal(BaseModel):
    id: str
    title: str
    description: str
    proposer: str
    votes_for: int
    votes_against: int
    status: str
    created_at: datetime
    ends_at: datetime


proposals_db = {}


@router.post("/proposals", response_model=Proposal)
async def create_proposal(proposal: ProposalCreate):
    """Create a new governance proposal"""
    from uuid import uuid4
    
    proposal_id = str(uuid4())
    new_proposal = {
        'id': proposal_id,
        'title': proposal.title,
        'description': proposal.description,
        'proposer': '0x0',  # TODO: Get from auth
        'votes_for': 0,
        'votes_against': 0,
        'status': 'active',
        'created_at': datetime.utcnow(),
        'ends_at': datetime.utcnow()
    }
    
    proposals_db[proposal_id] = new_proposal
    return Proposal(**new_proposal)


@router.get("/proposals", response_model=List[Proposal])
async def list_proposals(status: Optional[str] = None):
    """List all governance proposals"""
    proposals = list(proposals_db.values())
    
    if status:
        proposals = [p for p in proposals if p['status'] == status]
    
    return [Proposal(**p) for p in proposals]


@router.get("/proposals/{proposal_id}", response_model=Proposal)
async def get_proposal(proposal_id: str):
    """Get proposal by ID"""
    if proposal_id not in proposals_db:
        raise HTTPException(status_code=404, detail="Proposal not found")
    
    return Proposal(**proposals_db[proposal_id])


@router.post("/proposals/{proposal_id}/vote")
async def vote_on_proposal(proposal_id: str, support: bool):
    """Vote on a proposal"""
    if proposal_id not in proposals_db:
        raise HTTPException(status_code=404, detail="Proposal not found")
    
    proposal = proposals_db[proposal_id]
    
    if support:
        proposal['votes_for'] += 1
    else:
        proposal['votes_against'] += 1
    
    return {
        "success": True,
        "proposal_id": proposal_id,
        "support": support
    }
