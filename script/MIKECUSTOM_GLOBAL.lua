-- MIKECUSTOM_GLOBAL.lua
-- Archivo global de utilidades (by Mike Warp)
-- Contiene funciones para el soporte de los arquetipos Nordic / Aesir

MIKE_IMPORTED = true

--[[
Agrega esto al inicio de todas tus cartas que usen estas funciones:
if not MIKE_IMPORTED then Duel.LoadScript("MIKECUSTOM_GLOBAL.lua") end
]]

--------------------------------------------
-- 🔹 Funciones de grupo
--------------------------------------------

-- Todos los "Nordic" (incluye todas las subfamilias)
function IsNordic(c)
    return c:IsSetCard(0x42)
        or c:IsSetCard(0x3042)
        or c:IsSetCard(0x6042)
        or c:IsSetCard(0xa042)
        or c:IsSetCard(0x5042)
        or c:IsSetCard(0x41a)
end

-- Subgrupos específicos
function IsNordicAscendant(c)
    return c:IsSetCard(0x3042)
end

function IsNordicBeast(c)
    return c:IsSetCard(0x6042)
end

function IsNordicAlfar(c)
    return c:IsSetCard(0xa042)
end

function IsNordicRelic(c)
    return c:IsSetCard(0x5042)
end

function IsNordicHorror(c)
    return c:IsSetCard(0x41a)
end

-- Dioses Nórdicos ("Aesir")
function IsAesir(c)
    return c:IsSetCard(0x4b)
end

-------------------------------