Extension { #name : 'Behavior' }

{ #category : '*Tool-Profilers' }
Behavior >> instanceCount [
	"Answer the number of instances of the receiver that are currently in use.
	Note: we do not use #allInstances as allInstancesDo: has a fallback for low memory"

	| count |
	count := 0.
	self allInstancesDo: [:x | count := count + 1].
	^count
]
