{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE TemplateHaskell #-}

module Monomer.Common.LensStyle where

import Control.Lens.TH (abbreviatedFields, makeLensesWith)

import Monomer.Common.Style

makeLensesWith abbreviatedFields ''Margin
makeLensesWith abbreviatedFields ''Padding
makeLensesWith abbreviatedFields ''BorderSide
makeLensesWith abbreviatedFields ''Border
makeLensesWith abbreviatedFields ''Radius
makeLensesWith abbreviatedFields ''TextStyle
makeLensesWith abbreviatedFields ''StyleState
makeLensesWith abbreviatedFields ''Style
