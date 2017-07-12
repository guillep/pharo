[
| options architecture |

options := CommandLineArguments default.
architecture := options optionAt: 'ARCH' ifAbsent: [ '32' ].
directory := options optionAt: 'repository' ifAbsent: [ '.' ].

FileStream stdout
	nextPutAll: ('[INFO] Building Image Arch ', architecture);
	cr.

"Configure logging"
(CustomStringStreamBeacon with: FileStream stdout)
	startFor: PBStepStartedSignal, PBStepFinishedSignal.

(CustomStringStreamBeacon with: 'bootstrap.log' asFileReference writeStream)
	startFor: PBStepStartedSignal, PBStepFinishedSignal, PBSubStepFinishedSignal.

(PBBootstrap forArchitecture: architecture)
	repositoryDirectory: directory
	prepareBootstrap;
	createImage

] on: Warning do: #resume
