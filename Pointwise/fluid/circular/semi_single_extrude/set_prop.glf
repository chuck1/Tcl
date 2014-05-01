# Pointwise V17.0 Journal file - Mon Oct  7 21:39:09 2013

package require PWI_Glyph 2.17.0

pw::Application setUndoMaximumLevels 5
pw::Application reset
pw::Application markUndoLevel {Journal Reset}

pw::Application clearModified

pw::Database setModelSize 1
pw::Grid setNodeTolerance 9.9999999999999995e-08
pw::Grid setConnectorTolerance 9.9999999999999995e-08
pw::Application markUndoLevel {Modify Tolerances}

