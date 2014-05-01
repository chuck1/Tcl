# Pointwise V17.0 Journal file - Wed Oct  2 17:12:12 2013

package require PWI_Glyph 2.17.0

pw::Application setUndoMaximumLevels 5

set _TMP(mode_8) [pw::Application begin Create]
  set _DM(1) [pw::GridEntity getByName "dom-10"]
  set _DM(2) [pw::GridEntity getByName "dom-7"]
  set _DM(3) [pw::GridEntity getByName "dom-6"]
  set _DM(4) [pw::GridEntity getByName "dom-5"]
  set _DM(5) [pw::GridEntity getByName "dom-4"]
  set _DM(6) [pw::GridEntity getByName "dom-8"]
  set _DM(7) [pw::GridEntity getByName "dom-9"]
  set _DM(8) [pw::GridEntity getByName "dom-3"]
  set _TMP(PW_8) [pw::FaceStructured createFromDomains [list $_DM(1) $_DM(2) $_DM(3) $_DM(4) $_DM(5) $_DM(6) $_DM(7) $_DM(8)]]
  set _TMP(face_11) [lindex $_TMP(PW_8) 0]
  set _TMP(face_12) [lindex $_TMP(PW_8) 1]
  set _TMP(face_13) [lindex $_TMP(PW_8) 2]
  set _TMP(face_14) [lindex $_TMP(PW_8) 3]
  unset _TMP(PW_8)
  set _TMP(extStrBlock_1) [pw::BlockStructured create]
  $_TMP(extStrBlock_1) addFace $_TMP(face_11)
  set _TMP(extStrBlock_2) [pw::BlockStructured create]
  $_TMP(extStrBlock_2) addFace $_TMP(face_12)
  set _TMP(extStrBlock_3) [pw::BlockStructured create]
  $_TMP(extStrBlock_3) addFace $_TMP(face_13)
  set _TMP(extStrBlock_4) [pw::BlockStructured create]
  $_TMP(extStrBlock_4) addFace $_TMP(face_14)
$_TMP(mode_8) end
unset _TMP(mode_8)
set _TMP(mode_9) [pw::Application begin ExtrusionSolver [list $_TMP(extStrBlock_1) $_TMP(extStrBlock_2) $_TMP(extStrBlock_3) $_TMP(extStrBlock_4)]]
  $_TMP(mode_9) setKeepFailingStep true
  $_TMP(extStrBlock_1) setExtrusionSolverAttribute Mode Translate
  $_TMP(extStrBlock_2) setExtrusionSolverAttribute Mode Translate
  $_TMP(extStrBlock_3) setExtrusionSolverAttribute Mode Translate
  $_TMP(extStrBlock_4) setExtrusionSolverAttribute Mode Translate
  $_TMP(extStrBlock_1) setExtrusionSolverAttribute TranslateDirection {1 0 0}
  $_TMP(extStrBlock_2) setExtrusionSolverAttribute TranslateDirection {1 0 0}
  $_TMP(extStrBlock_3) setExtrusionSolverAttribute TranslateDirection {1 0 0}
  $_TMP(extStrBlock_4) setExtrusionSolverAttribute TranslateDirection {1 0 0}
  set _BL(1) [pw::GridEntity getByName "blk-1"]
  set _BL(2) [pw::GridEntity getByName "blk-2"]
  set _BL(3) [pw::GridEntity getByName "blk-3"]
  set _BL(4) [pw::GridEntity getByName "blk-4"]
  set _CN(1) [pw::GridEntity getByName "con-31"]
  $_TMP(extStrBlock_1) setExtrusionSolverAttribute TranslateDirection {0 0 1}
  $_TMP(extStrBlock_2) setExtrusionSolverAttribute TranslateDirection {0 0 1}
  $_TMP(extStrBlock_3) setExtrusionSolverAttribute TranslateDirection {0 0 1}
  $_TMP(extStrBlock_4) setExtrusionSolverAttribute TranslateDirection {0 0 1}
  $_TMP(extStrBlock_1) setExtrusionSolverAttribute TranslateDistance 1
  $_TMP(extStrBlock_2) setExtrusionSolverAttribute TranslateDistance 1
  $_TMP(extStrBlock_3) setExtrusionSolverAttribute TranslateDistance 1
  $_TMP(extStrBlock_4) setExtrusionSolverAttribute TranslateDistance 1
  $_TMP(mode_9) run 10
$_TMP(mode_9) end
unset _TMP(mode_9)
unset _TMP(extStrBlock_4)
unset _TMP(extStrBlock_3)
unset _TMP(extStrBlock_2)
unset _TMP(extStrBlock_1)
pw::Application markUndoLevel {Extrude, Translate}

unset _TMP(face_14)
unset _TMP(face_13)
unset _TMP(face_12)
unset _TMP(face_11)
