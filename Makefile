singularity: clean-singularity build-singularity

clean-singularity:
	sudo rm -rf sh_container

build-singularity:
	sudo singularity build sh_container Singularity

docker:
	docker build -t sh_container .
