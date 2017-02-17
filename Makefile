destroy:
	@vagrant destroy --force
	@rm -rf tmp_deploying_stage
	@rm -rf /tmp/rexray/volumes

create:
	@vagrant up -d

recreate:
	@make destroy
	@make create

stop:
	@VBoxManage controlvm swarmnode4 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm swarmnode3 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm swarmnode2 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm swarmnode1 acpipowerbutton 2>/dev/null || true

start:
	@VBoxManage startvm swarmnode1 --type headless 2>/dev/null || true
	@VBoxManage startvm swarmnode2 --type headless 2>/dev/null || true
	@VBoxManage startvm swarmnode3 --type headless 2>/dev/null || true
	@VBoxManage startvm swarmnode4 --type headless 2>/dev/null || true

status:
	@VBoxManage list runningvms
