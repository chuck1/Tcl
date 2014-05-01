# Pointwise V17.0 Journal file - Fri Nov 15 15:50:15 2013

package require PWI_Glyph 2.17.0

pw::Application setUndoMaximumLevels 5
pw::Application reset
pw::Application markUndoLevel {Journal Reset}

pw::Application clearModified

set _TMP(mode_1) [pw::Application begin Create]
  set _TMP(PW_1) [pw::SegmentSpline create]
  $_TMP(PW_1) delete
  unset _TMP(PW_1)
  set _TMP(PW_2) [pw::SegmentCircle create]
  $_TMP(PW_2) addPoint {1 0 0}
  $_TMP(PW_2) addPoint {0 0 0}
  $_TMP(PW_2) setEndAngle 45 {0 0 1}
  set _TMP(con_1) [pw::Connector create]
  $_TMP(con_1) addSegment $_TMP(PW_2)
  $_TMP(con_1) calculateDimension
  unset _TMP(PW_2)
$_TMP(mode_1) end
unset _TMP(mode_1)
pw::Application markUndoLevel {Create Connector}

unset _TMP(con_1)
