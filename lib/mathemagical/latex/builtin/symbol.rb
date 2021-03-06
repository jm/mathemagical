module Mathemagical::LaTeX::Builtin
	module Symbol
		MAP = {
"{"=>[[:s,:o],""],
"}"=>[[:s,:o],""],
"#"=>[[:s,:o],""],
"$"=>[[:s,:o],""],
"&"=>[[:s,:o],:amp],
"_"=>[[:s,:o],""],
"%"=>[[:s,:o],""],
","=>nil,
"varepsilon"=>[[:s,:I],],
"mathdollar"=>[[:s,:o],"$"],
"lbrace"=>[[:s],],
"rbrace"=>[[:s],],
"P"=>[[:s,:o],:para],
"mathparagraph"=>[[:s,:o],:para],
"S"=>[[:s,:o],:sect],
"mathsection"=>[[:s,:o],:sect],
"dag"=>[[:s,:o],:dagger],
"dagger"=>[[:s],],
"ddag"=>[[:s,:o],:ddagger],
"ddagger"=>[[:s],],
"copyright"=>[[:s,:o],:copy],
"pounds"=>[[:s,:o],:pound],
"mathsterling"=>[[:s,:o],:pound],
"dots"=>[[:s,:o],:mldr],
"mathellipsis"=>[[:s,:o],:mldr],
"ldots"=>[[:s,:o],:mldr],
"ensuremath"=>nil,
"|"=>[[:s,:o],:DoubleVerticalBar],
"mho"=>[[:s],],
"Join"=>[[:s,:o],:bowtie],
"Box"=>[[:s,:o],:square],
"Diamond"=>[[:s],],
"leadsto"=>[[:s,:o],:zigrarr],
"sqsubset"=>[[:s],],
"sqsupset"=>[[:s],],
"lhd"=>[[:s,:o],:vltri],
"unlhd"=>[[:s,:o],:ltrie],
"rhd"=>[[:s,:o],:vrtri],
"unrhd"=>[[:s,:o],:rtrie],
"log"=>[[:s,:i],""],
"lg"=>[[:s,:i],""],
"ln"=>[[:s,:i],""],
"lim"=>[[:u,:i],""],
"limsup"=>[[:u,:i],"lim sup"],
"liminf"=>[[:u,:i],"lim inf"],
"sin"=>[[:s,:i],""],
"arcsin"=>[[:s,:i],""],
"sinh"=>[[:s,:i],""],
"cos"=>[[:s,:i],""],
"arccos"=>[[:s,:i],""],
"cosh"=>[[:s,:i],""],
"tan"=>[[:s,:i],""],
"arctan"=>[[:s,:i],""],
"tanh"=>[[:s,:i],""],
"cot"=>[[:s,:i],""],
"coth"=>[[:s,:i],""],
"sec"=>[[:s,:i],""],
"csc"=>[[:s,:i],""],
"max"=>[[:u,:i],""],
"min"=>[[:u,:i],""],
"sup"=>[[:u,:i],""],
"inf"=>[[:u,:i],""],
"arg"=>[[:s,:i],""],
"ker"=>[[:s,:i],""],
"dim"=>[[:s,:i],""],
"hom"=>[[:s,:i],""],
"det"=>[[:u,:i],""],
"exp"=>[[:s,:i],""],
"Pr"=>[[:u,:i],""],
"gcd"=>[[:u,:i],""],
"deg"=>[[:s,:i],""],
"prime"=>[[:s],],
"alpha"=>[[:s,:I],],
"beta"=>[[:s,:I],],
"gamma"=>[[:s,:I],],
"delta"=>[[:s,:I],],
"epsilon"=>[[:s,:I],],
"zeta"=>[[:s,:I],],
"eta"=>[[:s,:I],],
"theta"=>[[:s,:I],],
"iota"=>[[:s,:I],],
"kappa"=>[[:s,:I],],
"lambda"=>[[:s,:I],],
"mu"=>[[:s,:I],],
"nu"=>[[:s,:I],],
"xi"=>[[:s,:I],],
"pi"=>[[:s,:I],],
"rho"=>[[:s,:I],],
"sigma"=>[[:s,:I],],
"tau"=>[[:s,:I],],
"upsilon"=>[[:s,:I],],
"phi"=>[[:s,:I],],
"chi"=>[[:s,:I],],
"psi"=>[[:s,:I],],
"omega"=>[[:s,:I],],
"vartheta"=>[[:s,:I],],
"varpi"=>[[:s,:I],],
"varrho"=>[[:s,:I],],
"varsigma"=>[[:s,:I],],
"varphi"=>[[:s,:I],],
"Gamma"=>[[:s,:i],],
"Delta"=>[[:s,:i],],
"Theta"=>[[:s,:i],],
"Lambda"=>[[:s,:i],],
"Xi"=>[[:s,:i],],
"Pi"=>[[:s,:i],],
"Sigma"=>[[:s,:i],],
"Upsilon"=>[[:s,:i],:Upsi],
"Phi"=>[[:s,:i],],
"Psi"=>[[:s,:i],],
"Omega"=>[[:s,:i],],
"aleph"=>[[:s,:i],],
"hbar"=>[[:s,:i],:hslash],
"imath"=>[[:s,:i],],
"jmath"=>[[:s,:i],],
"ell"=>[[:s],],
"wp"=>[[:s],],
"Re"=>[[:s,:i],],
"Im"=>[[:s,:i],],
"partial"=>[[:s,:o],:part],
"infty"=>[[:s,:n],:infin],
"emptyset"=>[[:s,:i],:empty],
"nabla"=>[[:s,:i],],
"surd"=>[[:s,:o],:Sqrt],
"top"=>[[:s],],
"bot"=>[[:s],],
"angle"=>[[:s],],
"not"=>[[:s],],
"triangle"=>[[:s],],
"forall"=>[[:s],],
"exists"=>[[:s,:o],:exist],
"neg"=>[[:s,:o],:not],
"lnot"=>[[:s,:o],:not],
"flat"=>[[:s],],
"natural"=>[[:s],],
"sharp"=>[[:s],],
"clubsuit"=>[[:s],],
"diamondsuit"=>[[:s],],
"heartsuit"=>[[:s],],
"spadesuit"=>[[:s],],
"coprod"=>[[:u],],
"bigvee"=>[[:u],],
"bigwedge"=>[[:u],],
"biguplus"=>[[:u],],
"bigcap"=>[[:u],],
"bigcup"=>[[:u],],
"intop"=>[[:u,:o],:int],
"int"=>[[:s,:o],],
"prod"=>[[:u],],
"sum"=>[[:u],],
"bigotimes"=>[[:u],],
"bigoplus"=>[[:u],],
"bigodot"=>[[:u],],
"ointop"=>[[:u,:o],:oint],
"oint"=>[[:s],],
"bigsqcup"=>[[:u],],
"smallint"=>[[:u,:o],:int],
"triangleleft"=>[[:s],],
"triangleright"=>[[:s],],
"bigtriangleup"=>[[:s],],
"bigtriangledown"=>[[:s],],
"wedge"=>[[:s],],
"land"=>[[:s,:o],:wedge],
"vee"=>[[:s],],
"lor"=>[[:s,:o],:vee],
"cap"=>[[:s],],
"cup"=>[[:s],],
"sqcap"=>[[:s],],
"sqcup"=>[[:s],],
"uplus"=>[[:s],],
"amalg"=>[[:s],],
"diamond"=>[[:s],],
"bullet"=>[[:s],],
"wr"=>[[:s],],
"div"=>[[:s],],
"odot"=>[[:s],],
"oslash"=>[[:s],],
"otimes"=>[[:s],],
"ominus"=>[[:s],],
"oplus"=>[[:s],],
"mp"=>[[:s],],
"pm"=>[[:s],],
"circ"=>[[:s,:o],:cir],
"bigcirc"=>[[:s],],
"setminus"=>[[:s],],
"cdot"=>[[:s,:o],:sdot],
"ast"=>[[:s],],
"times"=>[[:s],],
"star"=>[[:s],],
"propto"=>[[:s],],
"sqsubseteq"=>[[:s],],
"sqsupseteq"=>[[:s],],
"parallel"=>[[:s],],
"mid"=>[[:s],],
"dashv"=>[[:s],],
"vdash"=>[[:s],],
"nearrow"=>[[:s],],
"searrow"=>[[:s],],
"nwarrow"=>[[:s],],
"swarrow"=>[[:s],],
"Leftrightarrow"=>[[:s],],
"Leftarrow"=>[[:s],],
"Rightarrow"=>[[:s],],
"neq"=>[[:s,:o],:ne],
"ne"=>[[:s],],
"leq"=>[[:s],],
"le"=>[[:s],],
"geq"=>[[:s],],
"ge"=>[[:s],],
"succ"=>[[:s],],
"prec"=>[[:s],],
"approx"=>[[:s],],
"succeq"=>[[:s,:o],:sccue],
"preceq"=>[[:s,:o],:prcue],
"supset"=>[[:s],],
"subset"=>[[:s],],
"supseteq"=>[[:s],],
"subseteq"=>[[:s],],
"in"=>[[:s],],
"ni"=>[[:s],],
"owns"=>[[:s,:o],:ni],
"gg"=>[[:s],],
"ll"=>[[:s],],
"leftrightarrow"=>[[:s],],
"leftarrow"=>[[:s],],
"gets"=>[[:s,:o],:leftarrow],
"rightarrow"=>[[:s],],
"to"=>[[:s,:o],:rightarrow],
"mapstochar"=>[[:s,:o],:vdash],
"mapsto"=>[[:s],],
"sim"=>[[:s],],
"simeq"=>[[:s],],
"perp"=>[[:s],],
"equiv"=>[[:s],],
"asymp"=>[[:s],],
"smile"=>[[:s],],
"frown"=>[[:s],],
"leftharpoonup"=>[[:s],],
"leftharpoondown"=>[[:s],],
"rightharpoonup"=>[[:s],],
"rightharpoondown"=>[[:s],],
"cong"=>[[:s],],
"notin"=>[[:s],],
"rightleftharpoons"=>[[:s],],
"doteq"=>[[:s],],
"joinrel"=>nil,
"relbar"=>[[:s,:o],"-"],
"Relbar"=>[[:s,:o],"="],
"lhook"=>[[:s,:o],:sub],
"hookrightarrow"=>[[:s],],
"rhook"=>[[:s,:o],:sup],
"hookleftarrow"=>[[:s],],
"bowtie"=>[[:s],],
"models"=>[[:s],],
"Longrightarrow"=>[[:s],],
"longrightarrow"=>[[:s],],
"longleftarrow"=>[[:s],],
"Longleftarrow"=>[[:s],],
"longmapsto"=>[[:s,:o],:mapsto],
"longleftrightarrow"=>[[:s],],
"Longleftrightarrow"=>[[:s],],
"iff"=>[[:s],],
"ldotp"=>[[:s,:o],"."],
"cdotp"=>[[:s,:o],:cdot],
"colon"=>[[:s],],
"cdots"=>[[:s,:o],:ctdot],
"vdots"=>[[:s,:o],:vellip],
"ddots"=>[[:s,:o],:dtdot],
"braceld"=>[[:s,:o],0x25dc],
"bracerd"=>[[:s,:o],0x25dd],
"bracelu"=>[[:s,:o],0x25df],
"braceru"=>[[:s,:o],0x25de],
"lmoustache"=>[[:s],],
"rmoustache"=>[[:s],],
"arrowvert"=>[[:s,:o],:vert],
"Arrowvert"=>[[:s,:o],:DoubleVerticalBar],
"Vert"=>[[:s,:o],:DoubleVerticalBar],
"vert"=>[[:s],],
"uparrow"=>[[:s],],
"downarrow"=>[[:s],],
"updownarrow"=>[[:s],],
"Uparrow"=>[[:s],],
"Downarrow"=>[[:s],],
"Updownarrow"=>[[:s],],
"backslash"=>[[:s,:o],"\\"],
"rangle"=>[[:s],],
"langle"=>[[:s],],
"rceil"=>[[:s],],
"lceil"=>[[:s],],
"rfloor"=>[[:s],],
"lfloor"=>[[:s],],
"lgroup"=>[[:s,:o],0x2570],
"rgroup"=>[[:s,:o],0x256f],
"bracevert"=>[[:s,:o],:vert],
"mathunderscore"=>[[:s,:o],"_"],
"square"=>[[:s],],
"rightsquigarrow"=>[[:s],],
"lozenge"=>[[:s],],
"vartriangleright"=>[[:s],],
"vartriangleleft"=>[[:s],],
"trianglerighteq"=>[[:s],],
"trianglelefteq"=>[[:s],],
"boxdot"=>[[:s,:o],:dotsquare],
"boxplus"=>[[:s],],
"boxtimes"=>[[:s],],
"blacksquare"=>[[:s],],
"centerdot"=>[[:s],],
"blacklozenge"=>[[:s],],
"circlearrowright"=>[[:s],],
"circlearrowleft"=>[[:s],],
"leftrightharpoons"=>[[:s],],
"boxminus"=>[[:s],],
"Vdash"=>[[:s],],
"Vvdash"=>[[:s],],
"vDash"=>[[:s],],
"twoheadrightarrow"=>[[:s],],
"twoheadleftarrow"=>[[:s],],
"leftleftarrows"=>[[:s],],
"rightrightarrows"=>[[:s],],
"upuparrows"=>[[:s],],
"downdownarrows"=>[[:s],],
"upharpoonright"=>[[:s],],
"restriction"=>[[:s,:o],:upharpoonright],
"downharpoonright"=>[[:s],],
"upharpoonleft"=>[[:s],],
"downharpoonleft"=>[[:s],],
"rightarrowtail"=>[[:s],],
"leftarrowtail"=>[[:s],],
"leftrightarrows"=>[[:s],],
"rightleftarrows"=>[[:s],],
"Lsh"=>[[:s],],
"Rsh"=>[[:s],],
"leftrightsquigarrow"=>[[:s],],
"looparrowleft"=>[[:s],],
"looparrowright"=>[[:s],],
"circeq"=>[[:s],],
"succsim"=>[[:s],],
"gtrsim"=>[[:s],],
"gtrapprox"=>[[:s],],
"multimap"=>[[:s],],
"therefore"=>[[:s],],
"because"=>[[:s],],
"doteqdot"=>[[:s],],
"Doteq"=>[[:s,:o],:doteqdot],
"triangleq"=>[[:s],],
"precsim"=>[[:s],],
"lesssim"=>[[:s],],
"lessapprox"=>[[:s],],
"eqslantless"=>[[:s],],
"eqslantgtr"=>[[:s],],
"curlyeqprec"=>[[:s],],
"curlyeqsucc"=>[[:s],],
"preccurlyeq"=>[[:s],],
"leqq"=>[[:s],],
"leqslant"=>[[:s,:o],:leq],
"lessgtr"=>[[:s],],
"backprime"=>[[:s],],
"risingdotseq"=>[[:s],],
"fallingdotseq"=>[[:s],],
"succcurlyeq"=>[[:s],],
"geqq"=>[[:s],],
"geqslant"=>[[:s,:o],:geq],
"gtrless"=>[[:s],],
"bigstar"=>[[:s],],
"between"=>[[:s],],
"blacktriangledown"=>[[:s],],
"blacktriangleright"=>[[:s],],
"blacktriangleleft"=>[[:s],],
"vartriangle"=>[[:s,:o],:triangle],
"blacktriangle"=>[[:s],],
"triangledown"=>[[:s],],
"eqcirc"=>[[:s],],
"lesseqgtr"=>[[:s],],
"gtreqless"=>[[:s],],
"lesseqqgtr"=>[[:s],],
"gtreqqless"=>[[:s],],
"Rrightarrow"=>[[:s],],
"Lleftarrow"=>[[:s],],
"veebar"=>[[:s],],
"barwedge"=>[[:s],],
"doublebarwedge"=>[[:s],],
"measuredangle"=>[[:s],],
"sphericalangle"=>[[:s,:o],:angsph],
"varpropto"=>[[:s],],
"smallsmile"=>[[:s,:o],:smile],
"smallfrown"=>[[:s,:o],:frown],
"Subset"=>[[:s],],
"Supset"=>[[:s],],
"Cup"=>[[:s],],
"doublecup"=>[[:s,:o],:Cup],
"Cap"=>[[:s],],
"doublecap"=>[[:s,:o],:Cap],
"curlywedge"=>[[:s],],
"curlyvee"=>[[:s],],
"leftthreetimes"=>[[:s],],
"rightthreetimes"=>[[:s],],
"subseteqq"=>[[:s],],
"supseteqq"=>[[:s],],
"bumpeq"=>[[:s],],
"Bumpeq"=>[[:s],],
"lll"=>[[:s,:o],:Ll],
"llless"=>[[:s,:o],:Ll],
"ggg"=>[[:s],],
"gggtr"=>[[:s,:o],:ggg],
"circledS"=>[[:s],],
"pitchfork"=>[[:s],],
"dotplus"=>[[:s],],
"backsim"=>[[:s],],
"backsimeq"=>[[:s],],
"complement"=>[[:s],],
"intercal"=>[[:s],],
"circledcirc"=>[[:s],],
"circledast"=>[[:s],],
"circleddash"=>[[:s],],
"lvertneqq"=>[[:s,:o],:lneqq],
"gvertneqq"=>[[:s,:o],:gneqq],
"nleq"=>[[:s,:o],0x2270],
"ngeq"=>[[:s,:o],0x2271],
"nless"=>[[:s],],
"ngtr"=>[[:s],],
"nprec"=>[[:s],],
"nsucc"=>[[:s],],
"lneqq"=>[[:s],],
"gneqq"=>[[:s],],
"nleqslant"=>[[:s],],
"ngeqslant"=>[[:s],],
"lneq"=>[[:s],],
"gneq"=>[[:s],],
"npreceq"=>[[:s,:o],:nprcue],
"nsucceq"=>[[:s,:o],:nsccue],
"precnsim"=>[[:s],],
"succnsim"=>[[:s],],
"lnsim"=>[[:s],],
"gnsim"=>[[:s],],
"nleqq"=>[[:s],],
"ngeqq"=>[[:s],],
"precneqq"=>[[:s,:o],0x2ab5],
"succneqq"=>[[:s,:o],0x2ab6],
"precnapprox"=>[[:s],],
"succnapprox"=>[[:s],],
"lnapprox"=>[[:s,:o],0x2a89],
"gnapprox"=>[[:s,:o],0x2a8a],
"nsim"=>[[:s],],
"ncong"=>[[:s],],
"diagup"=>[[:s,:o],0x2571],
"diagdown"=>[[:s,:o],0x2572],
"varsubsetneq"=>[[:s,:o],:subsetneq],
"varsupsetneq"=>[[:s,:o],:supsetneq],
"nsubseteqq"=>[[:s],],
"nsupseteqq"=>[[:s],],
"subsetneqq"=>[[:s],],
"supsetneqq"=>[[:s],],
"varsubsetneqq"=>[[:s,:o],:subsetneqq],
"varsupsetneqq"=>[[:s,:o],:supsetneqq],
"subsetneq"=>[[:s],],
"supsetneq"=>[[:s],],
"nsubseteq"=>[[:s],],
"nsupseteq"=>[[:s],],
"nparallel"=>[[:s],],
"nmid"=>[[:s],],
"nshortmid"=>[[:s,:o],:nmid],
"nshortparallel"=>[[:s,:o],:nparallel],
"nvdash"=>[[:s],],
"nVdash"=>[[:s],],
"nvDash"=>[[:s],],
"nVDash"=>[[:s],],
"ntrianglerighteq"=>[[:s],],
"ntrianglelefteq"=>[[:s],],
"ntriangleleft"=>[[:s],],
"ntriangleright"=>[[:s],],
"nleftarrow"=>[[:s],],
"nrightarrow"=>[[:s],],
"nLeftarrow"=>[[:s],],
"nRightarrow"=>[[:s],],
"nLeftrightarrow"=>[[:s],],
"nleftrightarrow"=>[[:s],],
"divideontimes"=>[[:s],],
"varnothing"=>[[:s],],
"nexists"=>[[:s],],
"Finv"=>[[:s,:o],0x2132],
"Game"=>[[:s,:o],"G"],
"eth"=>[[:s],],
"eqsim"=>[[:s],],
"beth"=>[[:s],],
"gimel"=>[[:s],],
"daleth"=>[[:s],],
"lessdot"=>[[:s],],
"gtrdot"=>[[:s],],
"ltimes"=>[[:s],],
"rtimes"=>[[:s],],
"shortmid"=>[[:s,:o],:mid],
"shortparallel"=>[[:s],],
"smallsetminus"=>[[:s,:o],:setminus],
"thicksim"=>[[:s,:o],:sim],
"thickapprox"=>[[:s,:o],:approx],
"approxeq"=>[[:s],],
"succapprox"=>[[:s],],
"precapprox"=>[[:s],],
"curvearrowleft"=>[[:s],],
"curvearrowright"=>[[:s],],
"digamma"=>[[:s],],
"varkappa"=>[[:s],],
"Bbbk"=>[[:s,:i],:kopf],
"hslash"=>[[:s],],
"backepsilon"=>[[:s],],
"ulcorner"=>[[:s,:o],:boxdr],
"urcorner"=>[[:s,:o],:boxdl],
"llcorner"=>[[:s,:o],:boxur],
"lrcorner"=>[[:s,:o],:boxul],
}

		DELIMITERS=[
"lmoustache",
"rmoustache",
"arrowvert",
"Arrowvert",
"Vert",
"vert",
"uparrow",
"downarrow",
"updownarrow",
"Uparrow",
"Downarrow",
"Updownarrow",
"backslash",
"rangle",
"langle",
"rbrace",
"lbrace",
"rceil",
"lceil",
"rfloor",
"lfloor",
"lgroup",
"rgroup",
"bracevert",
"ulcorner",
"urcorner",
"llcorner",
"lrcorner",
"{",
"|",
"}",
]
	end
end
