clean:
	vagrant destroy -f
	rm -rf src tmp_deploying_stage

create:
	vagrant up -d

recreate:
	make clean
	make create

stop:
	VBoxManage controlvm node4 acpipowerbutton
	VBoxManage controlvm node3 acpipowerbutton
	VBoxManage controlvm node2 acpipowerbutton
	VBoxManage controlvm node1 acpipowerbutton

start:
	VBoxManage startvm node1 --type headless
	VBoxManage startvm node2 --type headless
	VBoxManage startvm node3 --type headless
	VBoxManage startvm node4 --type headless

status:
	VBoxManage list runningvms
