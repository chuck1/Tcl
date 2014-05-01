# Pointwise V17.0 Journal file - Sun Sep 29 21:20:58 2013

package require PWI_Glyph 2.17.0

pw::Application setUndoMaximumLevels 5

set _TMP(mode_10) [pw::Application begin Create]
  set _TMP(PW_23) [pw::SegmentSpline create]
  set _CN(1) [pw::GridEntity getByName "con-5"]
  set _CN(2) [pw::GridEntity getByName "con-7"]
  $_TMP(PW_23) addPoint [$_CN(1) getPosition -arc 1]
  $_TMP(PW_23) addPoint [pw::Grid getPoint [list 1 $_CN(2)]]
  $_TMP(PW_23) setSlope Linear
  set _TMP(PW_24) [pw::SegmentSpline create]
  $_TMP(PW_24) delete
  unset _TMP(PW_24)
  set _TMP(con_11) [pw::Connector create]
  $_TMP(con_11) addSegment $_TMP(PW_23)
  $_TMP(con_11) calculateDimension
  unset _TMP(PW_23)
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Create Connector}

unset _TMP(con_11)
set _TMP(mode_10) [pw::Application begin Create]
  set _TMP(PW_25) [pw::SegmentSpline create]
  $_TMP(PW_25) addPoint [$_CN(1) getPosition -arc 1]
  $_TMP(PW_25) addPoint [pw::Grid getPoint [list 1 $_CN(2)]]
  set _TMP(PW_26) [pw::SegmentSpline create]
  $_TMP(PW_26) addPoint [$_TMP(PW_25) getPoint [$_TMP(PW_25) getPointCount]]
  $_TMP(PW_26) addPoint {0.000115219461458031 0.000433074076279974 0}
  set _TMP(PW_27) [pw::SegmentSpline create]
  $_TMP(PW_27) delete
  unset _TMP(PW_27)
  set _TMP(con_12) [pw::Connector create]
  $_TMP(con_12) addSegment $_TMP(PW_25)
  $_TMP(con_12) addSegment $_TMP(PW_26)
  $_TMP(con_12) calculateDimension
  unset _TMP(PW_25)
  unset _TMP(PW_26)
$_TMP(mode_10) end
unset _TMP(mode_10)
pw::Application markUndoLevel {Create Connector}

unset _TMP(con_12)
set _TMP(mode_10) [pw::Application begin Create]
  set _TMP(PW_28) [pw::SegmentSpline create]
  $_TMP(PW_28) delete
  unset _TMP(PW_28)
$_TMP(mode_10) abort
unset _TMP(mode_10)
