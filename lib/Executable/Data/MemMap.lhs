This module is intended to contain a fast map of a process image.

Regular maps and arrays both fall short here, because it is too sparse for an array, but has dense patches making a map inefficient. Instead I am constructing something that could be described as a region map, which is basically a map of arrays.


\begin{code}
module Executable.Data.MemMap (emptyMemMap, MemMap, Word64, RWX(..), insert, MemRegion(..), rwxE) where
import Data.Word
import qualified Data.IntervalMap.FingerTree as IV
import qualified Data.ByteString as BS
import qualified Data.Set as S

data RWX = RWX { rwxR     :: Bool
               , rwxW     :: Bool
               , rwxX     :: Bool
               , rwxExtra :: S.Set Int
               }

rwxE :: RWX
rwxE = RWX False False False S.empty

data MemRegion = MR {mrPayload :: BS.ByteString
                    ,mrPerms :: RWX
                    }

data MemMap = MM (IV.IntervalMap Word64 MemRegion)

emptyMemMap :: MemMap
emptyMemMap = MM IV.empty

insert :: Word64 -> MemRegion -> MemMap -> MemMap
insert k v (MM m) =
  let end = k + (fromIntegral $ BS.length $ mrPayload v) - 1 in
  MM $ IV.insert (IV.Interval k end) v m
\end{code}
