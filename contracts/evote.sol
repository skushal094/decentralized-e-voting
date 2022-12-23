pragma solidity >=0.4.22 <0.6.0;

contract evote {
    struct Voter {
        uint256 vid;
        bool voted;
        uint256 vote;
        bool registered;
        address vadd;
        string email;
        uint256 con_id;
        string constituency;
    }

    struct Candidate {
        uint256 cid;
        string name;
        uint256 voteCount;
        uint256 constituencyId;
        string constituencyName;
        string party_name;
    }

    struct VoterId {
        uint256 eid; //ethereum id
        bytes32 hash;
    }

    struct Constituency {
        uint256 const_id;
        string const_name;
        uint256 winner_id;
    }

    address public admin;
    uint256 public voterCount = 0;
    mapping(uint256 => Voter) public voters;
    mapping(address => VoterId) public voterids;
    mapping(uint256 => Candidate) public candidates;
    mapping(uint256 => Constituency) public constituencies;
    uint256 public candidatesCount;
    bool public constituency_exist = false;
    uint256 public constituencyCount;
    uint256 public startVote;
    uint256 public endVote;
    uint256 public nowTime;

    constructor() public {
        admin = msg.sender;
    }

    function cancelReg(uint256 voter_id) public {
        if (msg.sender != admin) return;
        voters[voter_id].registered = false;
    }

    function setDates(uint256 startv, uint256 endv) public {
        if (msg.sender != admin || startv >= endv) return;
        startVote = startv;
        endVote = endv;
    }

    modifier onlyVote() {
        require(now > startVote && now <= endVote);
        _;
    }

    modifier onlyResult() {
        require(now > endVote);
        _;
    }

    function addCandidate(
        uint256 toCandidate,
        string memory _name,
        uint256 _constid,
        string memory _constname,
        string memory _partyname,
        uint256 votes
    ) public {
        if (msg.sender != admin) return;
        candidatesCount++;
        candidates[toCandidate].cid = toCandidate;
        candidates[toCandidate].name = _name;
        candidates[toCandidate].voteCount = votes;
        candidates[toCandidate].constituencyId = _constid;
        candidates[toCandidate].constituencyName = _constname;
        candidates[toCandidate].party_name = _partyname;

        for (uint256 i = 0; i < constituencyCount; i++) {
            if (constituencies[i].const_id == _constid) {
                constituency_exist = true;
            }
        }

        if (constituency_exist == false) {
            constituencyCount++;
            constituencies[_constid].const_id = _constid;
            constituencies[_constid].const_name = _constname;
            constituencies[_constid].winner_id = 0;
        }
    }

    function giveRightToVote(
        uint256 toVoter,
        string memory em,
        uint256 con_id,
        string memory cons
    ) public {
        if (msg.sender != admin) return;
        voterCount += 1;
        voters[toVoter].vid = toVoter;
        voters[toVoter].email = em;
        voters[toVoter].con_id = con_id;
        voters[toVoter].constituency = cons;
    }

    //need to include otp thing
    function registerToVote(uint256 toVoter) public {
        if (voters[toVoter].vid != 0 && voters[toVoter].registered == false) {
            voterids[msg.sender].eid = toVoter;
            voters[toVoter].registered = true;
            voters[toVoter].vadd = msg.sender;
        }
    }

    function storeHash(bytes32 _hash) public {
        voterids[msg.sender].hash = _hash;
    }

    function vote(uint256 toCandidate) public onlyVote {
        uint256 voterid;
        voterid = voterids[msg.sender].eid;
        if (voters[voterid].voted || voters[voterid].registered == false)
            return;

        voters[voterid].voted = true;

        voters[voterid].vote = toCandidate;
        candidates[toCandidate].voteCount += 1;
    }

    function winner() public view onlyResult returns (uint256 _winner) {
        uint256 winnerVoteCount = 0;
        for (uint256 cand = 1; cand < candidatesCount; cand++)
            if (candidates[cand].voteCount > winnerVoteCount) {
                winnerVoteCount = candidates[cand].voteCount;
                _winner = cand;
            }
    }

    function testKeccak(string memory s) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(s));
    }
}
