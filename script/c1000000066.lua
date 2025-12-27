-- Blasphemous Ascension
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

-----------------------------------------------------------
-- Wicked monster codes
-----------------------------------------------------------
s.wicked={
	[21208154]=true, -- The Wicked Avatar
	[62180201]=true, -- The Wicked Dreadroot
	[57793869]=true  -- The Wicked Eraser
}

-----------------------------------------------------------
-- Filter
-----------------------------------------------------------
function s.filter(c)
	return c:IsFaceup()
		and s.wicked[c:GetCode()]
		and c:GetFlagEffect(id)==0
end

-----------------------------------------------------------
-- Target
-----------------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
end

-----------------------------------------------------------
-- Activate
-----------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc then return end
	local c=e:GetHandler()

	-- Prevent reapplication
	tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_LEAVE,0,1)

	-------------------------------------------------------
	-- Effects cannot be negated
	-------------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e0)

	-------------------------------------------------------
	-- Attribute also treated as DIVINE
	-------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetValue(ATTRIBUTE_DIVINE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)

	-------------------------------------------------------
	-- Cannot be used as material for a Special Summon
	-------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetValue(aux.TRUE)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e2)

	-------------------------------------------------------
	-- Immune to other monsters' effects except DIVINE
	-------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.monimmune)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e3)


	-------------------------------------------------------
	-- Cannot be destroyed by Spell/Trap effects
	------------------------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(s.stindes)
	e4:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e4)
end

-----------------------------------------------------------
-- Immunity filters
-----------------------------------------------------------
function s.monimmune(e,re)
	return re:IsActiveType(TYPE_MONSTER)
		and not re:GetHandler():IsAttribute(ATTRIBUTE_DIVINE)
end

function s.stindes(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
