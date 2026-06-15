# Stage 05: Route Closeout And Archive

Route packet terminal closeout through the packet closeout lifecycle, then route implemented archive through the separate proposal archive lifecycle.

Required checks:

- Packet closeout reports `verdict: pass`.
- Packet closeout reports `archive_authorized: yes` before archive routing.
- Packet closeout does not archive directly.
- Archive relocation is followed by terminal freshness, implementation conformance, and post-implementation drift/churn validation.
- Fresh archive mutations block Change closeout until revalidated.
