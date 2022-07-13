function mouse = read( trial )

    mouse = yucca.mod.mouse.MouseInfo();
    
    mouse_data = trial.get_extlog_value_pairs_by_code('MOUSE', true);
    mouse.CageID = mouse_data.cid;
    mouse.EarMark = mouse_data.earmark;
    mouse.MouseID = mouse_data.aid;
    mouse.Note = mouse_data.note;
   
   
end

