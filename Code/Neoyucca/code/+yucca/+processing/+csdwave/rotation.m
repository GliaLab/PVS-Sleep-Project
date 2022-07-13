function rotation(ts)

app = roiman.App();
app.add_tool("manager", @roiman.tools.Manager);
app.add_tool("channel", @roiman.tools.Channel);
app.add_tool("rotation", @yucca.processing.csdwave.Rotation);
app.run();

vm = app.open(ts);

vm.data.write("rotation",0);

ch = yucca.processing.csdwave.ChannelRotation("Channel",1);
status = roiman.modules.StatusOverlay("Status");

vm.new_view(ts.name, [ch,status]);

end

