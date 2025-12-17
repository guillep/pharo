Extension { #name : 'CompiledCode' }

{ #category : '*DebugInfo' }
CompiledCode >> debugInfo [

	^ [ self fetchDebugInfo ]
		  on: Error
		  do: [ OnlineSourceDebugInfo for: self ]
]

{ #category : '*DebugInfo' }
CompiledCode >> fetchDebugInfo [

	| key metadataDictionary closurePath compressedDebugInfo |
	closurePath := '-' join: self pathOfLiteralIndexes.
	key := 'debugInfo' , (closurePath ifEmpty: [ '' ] ifNotEmpty: [ '-' , closurePath ]).
	metadataDictionary := STON fromString: (SourceFileArray default metadataAt: self sourcePointer).
	
	compressedDebugInfo := metadataDictionary at: key.
	^ STON fromString: compressedDebugInfo unzipped
]
