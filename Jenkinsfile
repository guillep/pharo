stage ("Fetch Requirements") {
    node('unix') {
		cleanWs()
		checkout scm
		dir ('builder') {
			sh 'wget -O - get.pharo.org/60+vm | bash'
			sh './pharo Pharo.image ../bootstrap/scripts/bootstrap.st --ARCH=32 --quit'
			sh 'ls'
		}
        stash includes: 'builder/**', name: 'pharo-builder'
		cleanWs()
    }
}

stage ("Bootstrap") {
    node('unix') {
		cleanWs()
		unstash 'pharo-builder'
		sh 'ls'
		dir ('builder') {
			sh 'ls'
			checkout scm
			sh './pharo Pharo.image ./bootstrap/scripts/bootstrap.st --ARCH=32 --quit'
			stash includes: 'bootstrap-cache/**', name: 'bootstrap'
		}	
        cleanWs()
    }
}

stage ("Full Image") {
    node('unix') {
		cleanWs()
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
				cleanWs()
                unstash 'bootstrap'
            }
        }
    }
    parallel builders
}