\begin{code}
module Executable.Container.ELF where
import Executable.Container.Type
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import Data.Elf
import Control.Spoon
import Control.DeepSeq
import qualified Data.Set as S
import Data.Char

-- TODO this feels sketchy, find a better way to absorb his exn
instance NFData Elf where

loadELF :: ByteString -> Maybe ExecContainer
loadELF rawELF = do
  parsedELF <- spoon $ parseElf rawELF
  arch      <- case elfMachine parsedELF of
                  EM_386    -> Just X86
                  EM_X86_64 -> Just X86_64
                  _         -> Nothing
  os        <- case (elfOSABI parsedELF, elfABIVersion parsedELF) of
                  (ELFOSABI_LINUX, _) -> Just Linux
                  _ -> Nothing
  let entry = elfEntry parsedELF
  let mem   = foldl loadSeg emptyMemMap (elfSegments parsedELF)
  let syms  = foldl loadSym emptySymtab (concat $ parseSymbolTables parsedELF)
  return $ EC { ecMemMap = mem
              , ecArch   = arch
              , ecEntry  = entry
              , ecOS     = os
              , ecSyms   = syms
              }
  where loadSym :: Symtab -> ElfSymbolTableEntry -> Symtab
        loadSym tab ste = case steName ste of
          (_, Just name) -> let
            base = steValue ste
            sym  = Sym { symName  = map (chr . fromIntegral) $ BS.unpack $ name
                       , symRange = (base, base + (steSize ste) - 1)
                       , symType  = transType $ steType ste}
            in insertSym sym tab
          _ -> tab
        transType :: ElfSymbolType -> Maybe SymType
        transType STTNoType  = Nothing
        transType STTObject  = Just Object
        transType STTFunc    = Just Func
        transType STTSection = Just Sect
        transType STTFile    = Just File
        transType _          = Nothing
        loadSeg :: MemMap -> ElfSegment -> MemMap
        loadSeg mem seg = let
          len     = elfSegmentMemSize seg
          base    = elfSegmentVirtAddr seg
          payload = pad len $ elfSegmentData seg
          perms   = foldl loadPerm rwxE $ elfSegmentFlags seg
          in insert base (MR {mrPayload = payload, mrPerms = perms}) mem
        pad :: Word64 -> ByteString -> ByteString
        pad tl' bs = let
          tl = fromIntegral tl'
          l  = BS.length bs
          in BS.append (BS.take tl bs) (BS.pack $ replicate (tl - l) 0)

        loadPerm :: RWX -> ElfSegmentFlag -> RWX
        loadPerm rwx sf = case sf of
          PF_X -> rwx {rwxX = True}
          PF_W -> rwx {rwxW = True}
          PF_R -> rwx {rwxR = True}
          PF_Ext n -> rwx {rwxExtra = S.insert n $ rwxExtra rwx}
\end{code}
