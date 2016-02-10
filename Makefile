# Makefile with some convenient quick ways to do common things

PROJECT = iminuit
CYTHON ?= cython

help:
	@echo ''
	@echo ' iminuit available make targets:'
	@echo ''
	@echo '     help             Print this help message (the default)'
	@echo ''
	@echo '     clean            Remove generated files'
	@echo '     build            Build inplace'
	@echo '     test             Run tests'
	@echo '     coverage         Run tests and write coverage report'
	@echo '     cython           Compile cython files'
	@echo '     doc              Run Sphinx to generate HTML docs'
	@echo '     doc-show         Open local HTML docs in browser'
	@echo ''
	@echo '     code-analysis    Run code analysis (flake8 and pylint)'
	@echo '     flake8           Run code analysis (flake8)'
	@echo '     pylint           Run code analysis (pylint)'
	@echo ''
	@echo ' Note that most things are done via `python setup.py`, we only use'
	@echo ' make for things that are not trivial to execute via `setup.py`.'
	@echo ''
	@echo ' Common `setup.py` commands:'
	@echo ''
	@echo '     python setup.py --help-commands'
	@echo '     python setup.py install'
	@echo '     python setup.py develop'
	@echo '     python setup.py test -V'
	@echo '     python setup.py test --help # to see available options'
	@echo '     python setup.py build_sphinx # use `-l` for clean build'
	@echo ''
	@echo ' More info:'
	@echo ''
	@echo ' * iminuit code: https://github.com/iminuit/iminuit'
	@echo ' * iminuit docs: https://iminuit.readthedocs.org/'
	@echo ''

clean:
	rm -rf build htmlcov doc/_build
	find . -name "*.pyc" -exec rm {} \;
	find . -name "*.so" -exec rm {} \;
	find . -name __pycache__ | xargs rm -fr

build:
	python setup.py build_ext --inplace

test: build
	python -m pytest -v iminuit

coverage: build
	python -m pytest -v iminuit --cov iminuit --cov-report html --cov-report term-missing --cov-report xml

# TODO: this runs Cython differently than via setup.py ... make it consistent!
cython:
	find $(PROJECT) -name "*.pyx" -exec $(CYTHON) --cplus  {} \;


# TODO: either of these give warnings or errors ... to be figured out!
doc: build FORCE
	cd doc && make html
	# python setup.py build_sphinx

FORCE:

doc-show:
	# open build/sphinx/html/index.html
	open doc/_build/html/index.html


code-analysis: flake8 pylint

flake8:
	flake8 --max-line-length=90 $(PROJECT) | grep -v __init__ | grep -v external

# TODO: once the errors are fixed, remove the -E option and tackle the warnings
pylint:
	pylint -E $(PROJECT)/ -d E1103,E0611,E1101 \
	       --ignore="" -f colorized \
	       --msg-template='{C}: {path}:{line}:{column}: {msg} ({symbol})'
