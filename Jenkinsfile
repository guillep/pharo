node('unix') {
	cleanWs()

	stage ("Fetch Requirements") {	
		checkout scm
		sh 'wget -O - get.pharo.org/60+vm | bash'
		sh './pharo Pharo.image bootstrap/scripts/prepare_image.st --save --quit'
    }

	def builders = [:]
	def architectures = ['32', '64']
	for (x in architectures) {
    // Need to bind the label variable before the closure - can't do 'for (label in labels)'
    def architecture = x

	builders[architecture] = {
		dir(architecture) {
		def currentDirectory = pwd()
		
		stage ("Bootstrap") {
			sh '../pharo ../Pharo.image bootstrap/scripts/bootstrap.st --ARCH=${architecture} --repository=${currentDirectory} --quit'
	    }

		stage ("Full Image") {
			sh 'bash ../bootstrap/scripts/build.sh -a ${label}'
			stash includes: 'bootstrap-cache/**', name: 'bootstrap${architecture}'
	    }
			
		}
	} // end build block
	
	} // end for architectures
	
	parallel builders
	cleanWs()
	
} // end node

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