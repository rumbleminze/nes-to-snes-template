
	; Old
	;.db     $B0,$44,$44,$BB,$BB,$BB,$BB,$BB,$BB
	;.db     $B3,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB

	; New
	; [b0] 5444abbbbbbbbbbb
	; [b3] bbbbbbbbbbbbbbbb
	db	$b0, $54, $44, $ab, $bb, $bb, $bb, $bb, $bb
	db	$b3, $bb, $bb, $bb, $bb, $bb, $bb, $bb, $bb