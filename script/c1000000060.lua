-- Obelisk's Unleashed Power
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

s.listed_names={10000000} -- Obelisk the Tormentor

-----------------------------------------------------------
-- Filtro: Obelisk sin efecto previo
-----------------------------------------------------------
function s.filter(c)
	return c:IsFaceup()
		and c:IsCode(10000000)
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
	-- Los efectos de Obelisk no pueden ser negados
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
	-- QUICK EFFECT: Tributa 2 → destruir todo + burn
	-------------------------------------------------------
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(TIMING_BATTLE_PHASE)
	e5:SetCondition(s.bpcon)
	e5:SetCost(s.bpcost)
	e5:SetTarget(s.bptg)
	e5:SetOperation(s.bpop)
	e5:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e5)
end

-----------------------------------------------------------
-- Funciones auxiliares
-----------------------------------------------------------

-- Solo permite tributo/material si es DIVINE
function s.relval(e,c)
	return not c:IsAttribute(ATTRIBUTE_DIVINE)
end

function s.matval(e,c)
	return not c:IsAttribute(ATTRIBUTE_DIVINE)
end

-- Inmunidad a monstruos no DIVINE
function s.immval(e,re)
	return re:IsActiveType(TYPE_MONSTER)
		and not re:GetHandler():IsAttribute(ATTRIBUTE_DIVINE)
end

-- Inmunidad a Spell/Trap activadas
function s.stimmune(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

-----------------------------------------------------------
-- Battle Phase wipe
-----------------------------------------------------------
function s.bpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase()
end

function s.bpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckReleaseGroupCost(tp,Card.IsReleasable,2,false,nil,nil)
	end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsReleasable,2,2,false,nil,nil)
	Duel.Release(g,REASON_COST)
end

function s.bptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.bpop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end

	-- Calcular ATK ANTES de destruir
	local atk=0
	for tc in g:Iter() do
		local a=tc:GetAttack()
		if a<0 then a=0 end
		atk=atk+a
	end

	-- Destruir
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
