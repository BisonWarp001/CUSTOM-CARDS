-- The Winged Dragon of Ra's Unleashed Power
local s,id=GetID()

function s.initial_effect(c)
	-- Activate (cannot be negated)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_names={10000010} -- The Winged Dragon of Ra

-----------------------------------------------------------
-- Filtro: Ra sin haber sido afectado
-----------------------------------------------------------
function s.filter(c)
	return c:IsFaceup()
		and c:IsCode(10000010)
		and c:GetFlagEffect(id)==0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
	end
end

-----------------------------------------------------------
-- Activación (WHEN THIS CARD RESOLVES)
-----------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc then return end

	local c=e:GetHandler()

	-- Marcar para no reaplicar
	tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_LEAVE,0,1)

	-------------------------------------------------------
	-- LIMPIEZA DE NEGACIONES (parte CLAVE)
	-------------------------------------------------------
	tc:ResetEffect(EFFECT_DISABLE,RESET_CODE)
	tc:ResetEffect(EFFECT_DISABLE_EFFECT,RESET_CODE)

	-------------------------------------------------------
	-- Los efectos de Ra no pueden ser negados
	-------------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e0)

	-------------------------------------------------------
	-- CLIENT HINT ÚNICO
	-------------------------------------------------------
	local eh=Effect.CreateEffect(c)
	eh:SetDescription(aux.Stringid(id,0))
	eh:SetType(EFFECT_TYPE_SINGLE)
	eh:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	eh:SetRange(LOCATION_MZONE)
	eh:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET) -- dummy
	eh:SetValue(aux.tgoval) -- dummy
	eh:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(eh)

	-------------------------------------------------------
	-- No puede ser tributado excepto por DIVINE
	-------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(s.relval)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)

	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	tc:RegisterEffect(e1b)

	-------------------------------------------------------
	-- No puede ser usado como material excepto DIVINE
	-------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetValue(s.matval)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e2)

	-------------------------------------------------------
	-- Inmune a efectos de monstruos excepto DIVINE
	-------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.immval)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e3)

	-------------------------------------------------------
	-- Inmune a Spell/Trap activadas
	-------------------------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.stimmune)
	e4:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e4)

	-------------------------------------------------------
	-- GAIN ATK/DEF (Quick / Ignition tipo Ra)
	-------------------------------------------------------
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(s.atkcost)
	e5:SetOperation(s.atkop)
	e5:SetReset(RESET_EVENT|RESETS_STANDARD)

	tc:RegisterEffect(e5)
end

-----------------------------------------------------------
-- Funciones auxiliares
-----------------------------------------------------------

function s.relval(e,c)
	return not c:IsAttribute(ATTRIBUTE_DIVINE)
end

function s.matval(e,c)
	return not c:IsAttribute(ATTRIBUTE_DIVINE)
end

function s.immval(e,re)
	return re:IsActiveType(TYPE_MONSTER)
		and not re:GetHandler():IsAttribute(ATTRIBUTE_DIVINE)
end

function s.stimmune(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

-----------------------------------------------------------
-- COSTE: tributar cualquier número de monstruos
-----------------------------------------------------------
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,c)
	if chk==0 then return #g>0 end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=g:Select(tp,1,#g,nil)

	-- Guardamos exactamente los seleccionados
	e:SetLabelObject(sg)
	Duel.Release(sg,REASON_COST)
end


-----------------------------------------------------------
-- Operación: usar ATK/DEF ACTUAL que tenían en el campo
-----------------------------------------------------------
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	if not g or #g==0 then return end

	local atk,def=0,0
	for tc in g:Iter() do
		atk=atk+math.max(tc:GetAttack(),0)
		def=def+math.max(tc:GetDefense(),0)
	end

	if atk>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end

	if def>0 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(def)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end

