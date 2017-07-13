node('unix') {
	cleanWs()
	def builders = [:]
	def architectures = ['32', '64']
	for (x in architectures) {
    // Need to bind the label variable before the closure - can't do 'for (label in labels)'
    def architecture = x

	builders[architecture] = {
		dir(architecture) {
		
		stage ("Fetch Requirements-${architecture}") {	
			checkout scm
			sh 'wget -O - get.pharo.org/60+vm | bash'
			sh './pharo Pharo.image bootstrap/scripts/prepare_image.st --save --quit'
	    }

		stage ("Bootstrap-${architecture}") {
			sh "./pharo ./Pharo.image bootstrap/scripts/bootstrap.st --ARCH=${architecture} --quit"
	    }

		stage ("Full Image-${architecture}") {
			sh "BOOTSTRAP_ARCH=${architecture} bash ./bootstrap/scripts/build.sh -a ${architecture}"
			stash includes: "bootstrap-cache/**", name: "bootstrap${architecture}"
	    }
		
		// labels for Jenkins node types we will build on
		def labels = ['unix', 'osx', 'windows']
		def testers = [:]
		for (x in labels) {
	        // Need to bind the label variable before the closure - can't do 'for (label in labels)'
	        def label = x
		    builders[label] = {
	            node(label) { stage("Tests-${label}-${architecture}"){
					cleanWs()
		            unstash 'bootstrap${architecture}'
					
					def urlprefix = ""
					if (${architecture} == 64 ) {
						urlprefix = "/64"
					}
					
					sh "wget -O - get.pharo.org${urlprefix}/vm70 | bash"
					sh "./pharo bootstrap-cache/Pharo.image test --junit-xml-output \".*\""
				}}
		    }
		}
		parallel testers
		
		}
	} // end build block
	
	} // end for architectures
	
	parallel builders
	cleanWs()
	
} // end node