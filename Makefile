NAMESPACE=tim77
APP=limbo

.PHONY: testall
testall: requirements
	tox

# to run a single file, with debugger support:
# pytest -s test/test_plugins/test_image.py
.PHONY: test
test: install
	LANG=en_US.UTF-8 pytest --cov=limbo --cov-report term-missing test

.PHONY: clean
clean:
	rm -rf build dist limbo.egg-info

.PHONY: run
run: install
	bin/limbo

.PHONY: repl
repl: install
	bin/limbo -t

.PHONY: requirements
requirements:
	pip install -r requirements.txt

.PHONY: install
install: requirements
	python setup.py install
	make clean

.PHONY: publish
publish:
	pandoc -s -w rst README.md -o README.rst
	python setup.py sdist upload
	rm README.rst

.PHONY: flake8
flake8:
	flake8 limbo test

.PHONY: docker_build
docker_build:
	docker build -f Dockerfile.test -t ${NAMESPACE}/${APP}-test .
	docker build --build-arg BASE=${NAMESPACE}/${APP}-test -f Dockerfile.run -t ${NAMESPACE}/${APP} .

.PHONY: docker_test
docker_test:
	docker run -e LANG=en_US.UTF-8 ${NAMESPACE}/${APP}-test

.PHONY: docker_run
docker_run:
	docker run -d -e SLACK_TOKEN=${SLACK_TOKEN} ${NAMESPACE}/${APP}

.PHONY: docker_stop
docker_stop:
	docker stop `docker ps -q --filter ancestor=${NAMESPACE}/${APP} --format="{{.ID}}"`
