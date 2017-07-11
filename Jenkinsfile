stage ("Fetch Requirements") {
    node('unix') {		
		dir ('builder') {
			sh 'wget https://github.com/guillep/PharoBootstrap/releases/download/v1.1/bootstrapImage.zip'
			sh 'wget -O - get.pharo.org/vm60 | bash'
			sh 'ls'
		}
		sh 'ls'
        stash includes: 'builder/**', name: 'pharo-builder'
		cleanWs()
    }
}

stage ("Bootstrap") {
    node('unix') {
		unstash 'pharo-builder'
		sh 'ls'
		dir ('builder') {
			checkout scm
			sh 'ls'
			sh './pharo Pharo.image ./bootstrap/scripts/bootstrap.st --ARCH=32 --quit'
			stash includes: 'bootstrap-cache/**', name: 'bootstrap'
		}	
        cleanWs()
    }
}

stage ("Full Image") {
    node('unix') {
		unstash 'bootstrap'
		checkout scm
		sh 'ls'
		dir ('bootstrap-cache') {
			sh 'ls'
			sh 'bash bootstrap/scripts/build.sh'
		}
		stash includes: 'bootstrap-cache/**', name: 'bootstrap'
        cleanWs()
    }
}

stage ("Test") {
    // labels for Jenkins node types we will build on
    def labels = ['unix', 'osx', 'windows']
	def parts = ['A-L', 'M-Z']
    def builders = [:]
    for (x in labels) {
        // Need to bind the label variable before the closure - can't do 'for (label in labels)'
        def label = x
        builders[label] = {
            node(label) {
                unstash 'bootstrap'
            }
        }
    }
    parallel builders
}