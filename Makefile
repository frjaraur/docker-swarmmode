destroy:
	@vagrant destroy -f
	@rm -rf tmp_deploying_stage

create:
	@vagrant up -d

recreate:
	@make destroy
	@make create

stop:
	@VBoxManage controlvm swarmnode4 acpipowerbutton
	@VBoxManage controlvm swarmnode3 acpipowerbutton
	@VBoxManage controlvm swarmnode2 acpipowerbutton
	@VBoxManage controlvm swarmnode1 acpipowerbutton

start:
	@VBoxManage startvm swarmnode1 --type headless
	@VBoxManage startvm swarmnode2 --type headless
	@VBoxManage startvm swarmnode3 --type headless
	@VBoxManage startvm swarmnode4 --type headless

status:
	@VBoxManage list runningvms
