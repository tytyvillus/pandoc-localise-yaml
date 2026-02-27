{-#LANGUAGE OverloadedStrings#-}

import qualified Data.Text as T
import qualified Data.Map as M
import Data.Maybe
import Text.Pandoc.JSON
import Text.Pandoc.Walk

type Text = T.Text -- shorthand

-- Which key in the metadata sets the localisation?
localityKey :: Text
localityKey = "lang" -- or "locality"

-- Extract localisation info from metadata
getLocalityInfo :: Meta -> [Text]
getLocalityInfo meta = catMaybes [longcode, shortcode]
  where longcode = case lookupMeta localityKey meta of
                        Just (MetaInlines [Str txt]) -> Just txt
                        _                            -> Nothing
        shortcode = fst <$> T.breakOn "-" <$> longcode

-- If applicable, pick the localisation <key>
newField :: Text -> MetaValue -> Maybe MetaValue
newField key (MetaMap x) = M.lookup key x
newField _ _ = Nothing

-- If applicable, pick localisation matching first element of <keys>
updateField :: [Text] -> MetaValue -> MetaValue
updateField keys metamap@(MetaMap _) = metamap `unless` newCandidates
  where newCandidates = catMaybes $ map (`newField` metamap) $ keys
        x `unless` ys = if null ys then x else head ys
updateField _ x = x

-- Go through whole metadata block performing substitutions
localise :: Meta -> Meta
localise meta = walk (updateField localities) meta
  where localities = getLocalityInfo meta

-- Main
main :: IO ()
main = toJSONFilter localise
