node('unix') {
	cleanWs()
	
	stage ("Fetch Requirements") {	
		checkout scm
		sh 'wget -O - get.pharo.org/60+vm | bash'
		sh './pharo Pharo.image bootstrap/scripts/prepare_image.st --save --quit'
    }

	stage ("Bootstrap") {
		sh './pharo Pharo.image bootstrap/scripts/bootstrap.st --ARCH=32 --quit'
    }

	stage ("Full Image") {
		sh 'bash bootstrap/scripts/build.sh'
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