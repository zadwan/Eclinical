// The 'eclinical' program.
program eclinical.aleo {
    // Study details
    struct StudyInfo {
        title: field,
        condition: field,
        age: i8,
        length: field,
        study: address,
    }

    // Study record records study info publicly
    record Study {
        owner: address,
        id: field,
        info: StudyInfo,
    }

    // Save study info in public storage.
    mapping studies: field => StudyInfo;

    // Privacy tickets to participate
    record Ticket {
        owner: address,
        pid: field,
    }

    // Count the total tickets issued for each study
    mapping tickets: field => u64;

    mapping agree_participate: field => u64;

    mapping disagree_participate: field => u64;

    // Propose a new study to participate in.
    transition propose(public info: StudyInfo) -> Study {
        // Authenticate proposer.
        assert_eq(self.caller, info.study);

        // Generate a new study id.
        let id: field = BHP256::hash_to_field(info.title);

        // Return a new record for the study.
        // Finalize the study id.
        return Study {
            owner: self.caller,
            id,
            info,
        } then finalize(id);
    }
    // Create a new study in the "tickets" mapping.
    finalize propose(public id: field) {
        Mapping::set(tickets, id, 0u64);
    }

    // Create a new ticket to participate with.
    transition new_ticket(
        public pid: field,
        public participant: address,
        public participantcondition: field,
        public participantage: i8,
    ) -> Ticket {

        // Finalize the participant id for the ticket.
        return Ticket {
            owner: participant,
            pid,
        } then finalize(pid);
    }
    // Create a new ticket for a study in the "tickets" mapping.
    finalize new_ticket(public pid: field) {
        let current: u64 = Mapping::get_or_use(tickets, pid, 0u64);
        Mapping::set(tickets, pid, current + 1u64);
    }

    // Vote privately to agree with a proposal.
    transition agree(ticket: Ticket) {
        // Finalize this vote.
        return then finalize(ticket.pid);
    }
    finalize agree(public pid: field) {
        // Publicly increment the number of agree votes.
        let current: u64 = Mapping::get_or_use(agree_participate, pid, 0u64);
        Mapping::set(agree_participate, pid, current + 1u64);
    }

    // Vote privately to disagree with a proposal.
    transition disagree(ticket: Ticket) {
        // Finalize this vote.
        return then finalize(ticket.pid);
    }
    finalize disagree(pid: field) {
        // Publicly increment the number of disagree votes.
        let current: u64 = Mapping::get_or_use(disagree_participate, pid, 0u64);
        Mapping::set(disagree_participate, pid, current + 1u64);
    }
}


