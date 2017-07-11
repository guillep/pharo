stage ("Checkout") {
    node('unix') {
        checkout scm
		sh "ls"
		stash includes: 'bootstrap/**', name: 'bootstrap-src'
        stash includes: 'src/**', name: 'pharo-src'
        cleanWs()
    }
}

stage ("Fetch Requirements") {
    node('unix') {
		
		dir ('builder') {
			unstash 'bootstrap-src'
			sh 'wget https://github.com/guillep/PharoBootstrap/releases/download/v1.1/bootstrapImage.zip'
			sh 'wget -O - get.pharo.org/vm60 | bash'
		}
        stash includes: 'builder/**', name: 'pharo-builder'
		cleanWs()
    }
}

stage ("Bootstrap") {
    node('unix') {
		unstash 'pharo-builder'
		dir ('builder') {
			unstash 'pharo-src'
			sh './pharo Pharo.image ./bootstrap/scripts/bootstrap.st --ARCH=32 --quit'
			stash includes: 'bootstrap-cache/**'; name: 'bootstrap'
		}	
        cleanWs()
    }
}

stage ("Full Image") {
    node('unix') {
		unstash 'pharo-builder'
		dir ('builder') {
			unstash 'bootstrap'
			sh 'bash bootstrap/scripts/build.sh'
		}
        cleanWs()
    }
}

stage ("Test") {
    // labels for Jenkins node types we will build on
    def labels = ['unix', 'osx', 'windows']
    def builders = [:]
    for (x in labels) {
        // Need to bind the label variable before the closure - can't do 'for (label in labels)'
        def label = x
        builders[label] = {
            node(label) {
                unstash "stashName"
                sh "ls"
            }
        }
    }
    parallel builders
}