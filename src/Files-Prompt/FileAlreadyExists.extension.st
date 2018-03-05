Extension { #name : #FileAlreadyExists }

{ #category : #'*Files-Prompt' }
FileAlreadyExists >> defaultAction [
	"The default action taken if the exception is signaled."

	^ UIManager default fileExistsDefaultAction: self
]
