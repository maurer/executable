\begin{code}
module Executable.Data.Symtab
( Sym(..)
, SymType(..)
, Symtab
, emptySymtab
, insertSym
, symByName
, symByAddr
) where
import qualified Data.Map as M
import qualified Data.IntervalMap.FingerTree as IV
import Data.Word

-- This will likely need to be extended later to include symbol
-- binding strength
data Sym = Sym { symName  :: String
               , symRange :: (Word64, Word64)
               , symType  :: Maybe SymType
               }
data SymType = Object
             | Func
             | Sect
             | File
data Symtab = Symtab { symStr :: M.Map String Sym
                     , symMap :: IV.IntervalMap Word64 Sym
                     }

emptySymtab :: Symtab
emptySymtab = Symtab M.empty IV.empty

insertSym :: Sym -> Symtab -> Symtab
insertSym sym tab = let
  (l, h) = symRange sym
  in tab { symStr = M.insert (symName sym) sym (symStr tab)
         , symMap = IV.insert (IV.Interval l h) sym (symMap tab)
         }

symByName :: String -> Symtab -> Maybe Sym
symByName n tab = M.lookup n (symStr tab)

symByAddr :: Word64 -> Symtab -> [Sym]
symByAddr n tab = map snd $ IV.search n (symMap tab)
\end{code}
