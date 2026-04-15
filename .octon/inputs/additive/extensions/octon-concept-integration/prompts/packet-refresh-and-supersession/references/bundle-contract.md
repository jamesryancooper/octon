# Packet Refresh And Supersession Bundle Contract

- input type: existing proposal packet
- output type: refreshed packet or superseding packet of the same proposal kind
- decision rule: keep packet kind and promotion intent unless live repo drift
  makes supersession necessary
- validators: packet-kind-specific proposal validators based on the packet kind
