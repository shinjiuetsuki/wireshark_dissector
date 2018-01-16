do
  local lwm2m_proto = Proto("lwm2m", "Lightweight M2M Protocol")

  local F_lw_operation = ProtoField.string("lw.operation", "LwM2M Operation")
  local F_lw_op_method = ProtoField.string("lw.opmethod", "Operation Method")
  local F_lw_endpoint = ProtoField.string("lw.ep", "End Point Name")
  local F_lw_lifetime = ProtoField.string("lw.lt", "Life Time")
  local F_lw_binding = ProtoField.string("lw.binding", "Binding")
  lwm2m_proto.fields = {F_lw_operation, F_lw_op_method, F_lw_endpoint, F_lw_lifetime, F_lw_binding}

  local uri_path = Field.new("coap.opt.uri_path")
  local uri_query = Field.new("coap.opt.uri_query")
  local coap_code = Field.new("coap.code")
  local original_coap_dissector

  function lwm2m_proto.dissector(buffer, pinfo, tree)
    original_coap_dissector:call(buffer, pinfo, tree)
    
    --[[
    local coap_methods = {
      [0x01] = "GET",
      [0x02] = "POST",
      [0x03] = "PUT",
      [0x04] = "DELETE",
    }
    local method_name = tostring(coap_methods[coap_code()])
	--]]
	
    if uri_path() then
     local path = tostring(uri_path())
     local opt_method = "default"

     if string.find(path, "rd") then
      local operation = "Registration"
      pinfo.cols.protocol = "CoAP(Registration)"
      
      if tostring(coap_code()) == tostring(2) then
		info(uri_query())
        if string.find(tostring(uri_query()), "ep") then
          local opt_method = "Initial REGISTER"
          info("enter code_num==2 and Ini loop")
          info(opt_method)
        else
          local opt_method = "UPDATE"
          info("enter code_num==2 and Up loop")
          info(opt_method)
        end
      else if coap_code() == 4 then
        local opt_method = "De-REGISTER"
        info(opt_method)
      else
        local opt_method = "Unknown"
        info(opt_method)
      end
      
      local subtree = tree:add(lwm2m_proto, buffer)
        subtree:add(F_lw_operation, buffer(), operation)
          :set_text("Operation : "..operation)
        subtree:add(F_lw_op_method, buffer(), opt_method)
          :set_text("Operation Method : "..opt_method)

     end
    end
  end
end
  local udp_dissector_table = DissectorTable.get("udp.port")
  original_coap_dissector = udp_dissector_table:get_dissector(5683)
  udp_dissector_table:add(5683, lwm2m_proto)
end
