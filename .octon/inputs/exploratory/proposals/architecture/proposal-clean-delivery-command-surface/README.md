# Clean Delivery Command Surface

This child packet proposes one explicit operator command or wrapper for proposal-program clean delivery.

The command should request clean delivery by invoking the existing proposal-program lifecycle runner with route execution enabled and `target_outcome=cleaned` bound as a request. It must not claim cleaned delivery, bypass route graph planning, or bypass delivery and closeout authority.
