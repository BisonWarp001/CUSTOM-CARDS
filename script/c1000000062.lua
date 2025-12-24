-- Unleashed Divine Power
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
s.listed_names={10000000,10000010,10000020}
-- Divine-Beast codes
s.gods={
	[10000000]=true, -- Obelisk
	[10000010]=true, -- Ra
	[10000020]=true  -- Slifer
}

-----------------------------------------------------------
-- Filter
-----------------------------------------------------------
function s.filter(c)
	return c:IsFaceup()
		and s.gods[c:GetCode()]
		and c:GetFlagEffect(id)==0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
	end
end

-----------------------------------------------------------
-- Activation (WHEN THIS CARD RESOLVES)
-----------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc then return end

	local c=e:GetHandler()

	-- Prevent reapplication
	tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_LEAVE,0,1)

	-------------------------------------------------------
	-- CLEAN NEGATIONS (Slifer-correct logic)
	-------------------------------------------------------
	tc:ResetEffect(EFFECT_DISABLE,RESET_CODE)
	tc:ResetEffect(EFFECT_DISABLE_EFFECT,RESET_CODE)

	-------------------------------------------------------
	-- Effects cannot be negated
	-------------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e0)

	-------------------------------------------------------
	-- CLIENT HINT (visual)
	-------------------------------------------------------
	local eh=Effect.CreateEffect(c)
	eh:SetDescription(aux.Stringid(id,0))
	eh:SetType(EFFECT_TYPE_SINGLE)
	eh:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	eh:SetRange(LOCATION_MZONE)
	eh:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET) -- dummy
	eh:SetValue(aux.tgoval)
	eh:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(eh)

	-------------------------------------------------------
	-- COMMON PROTECTIONS (IDENTICAL FOR ALL 3)
	-------------------------------------------------------
	s.apply_common(tc,c)

	-------------------------------------------------------
	-- GOD-SPECIFIC EFFECTS
	-------------------------------------------------------
	if tc:IsCode(10000010) then
		s.apply_ra(tc,c)
	elseif tc:IsCode(10000020) then
		s.apply_slifer(tc,c)
	elseif tc:IsCode(10000000) then
		s.apply_obelisk(tc,c)
	end
end

-----------------------------------------------------------
-- COMMON PROTECTIONS
-----------------------------------------------------------
function s.apply_common(tc,c)

	-- Cannot be material except DIVINE
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetValue(s.matval)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e2)

	-- Immune to non-DIVINE monster effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.immval)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e3)

	-- Immune to activated Spell/Trap effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.stimmune)
	e4:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e4)
end

-----------------------------------------------------------
-- SLIFER EFFECT
-----------------------------------------------------------
function s.apply_slifer(tc,c)
	local e=Effect.CreateEffect(c)
	e:SetDescription(aux.Stringid(id,1))
	e:SetCategory(CATEGORY_DEFCHANGE+CATEGORY_DESTROY)
	e:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e:SetRange(LOCATION_MZONE)
	e:SetCode(EVENT_SUMMON_SUCCESS)
	e:SetCondition(s.defcon)
	e:SetTarget(s.deftg)
	e:SetOperation(s.defop)
	e:SetReset(RESET_EVENT | RESETS_STANDARD)
	tc:RegisterEffect(e)

	local e2=e:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	tc:RegisterEffect(e2)
end

-----------------------------------------------------------
-- OBELISK EFFECT
-----------------------------------------------------------
function s.apply_obelisk(tc,c)
	local e=Effect.CreateEffect(c)
	e:SetDescription(aux.Stringid(id,2))
	e:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e:SetType(EFFECT_TYPE_QUICK_O)
	e:SetCode(EVENT_FREE_CHAIN)
	e:SetRange(LOCATION_MZONE)
	e:SetCondition(s.bpcon)
	e:SetCost(s.bpcost)
	e:SetOperation(s.bpop)
	e:SetReset(RESET_EVENT | RESETS_STANDARD)
	tc:RegisterEffect(e)
end

-----------------------------------------------------------
-- RA EFFECT
-----------------------------------------------------------
function s.apply_ra(tc,c)
	local e=Effect.CreateEffect(c)
	e:SetDescription(aux.Stringid(id,3))
	e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e:SetType(EFFECT_TYPE_IGNITION)
	e:SetRange(LOCATION_MZONE)
	e:SetCountLimit(1)
	e:SetCost(s.tributecost)
	e:SetOperation(s.tributeop)
	e:SetReset(RESET_EVENT | RESETS_STANDARD)
	tc:RegisterEffect(e)
end

-----------------------------------------------------------
-- AUXILIARY
-----------------------------------------------------------
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
-- SLIFER DEF REDUCTION
-----------------------------------------------------------
function s.defilter(c,tp)
	return c:IsControler(1-tp)
		and c:IsPosition(POS_FACEUP_DEFENSE)
end

function s.defcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.defilter,1,nil,tp)
end

function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg:Filter(s.defilter,nil,tp))
end

function s.defop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Match(Card.IsFaceup,nil)
	if #g==0 then return end

	local dg=Group.CreateGroup()
	for tc in g:Iter() do
		local pre=tc:GetDefense()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-2000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if pre~=0 and tc:GetDefense()==0 then
			dg:AddCard(tc)
		end
	end
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

-----------------------------------------------------------
-- OBELISK BATTLE PHASE WIPE
-----------------------------------------------------------
function s.bpcon(e,tp)
	return Duel.IsBattlePhase()
end

function s.bpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckReleaseGroupCost(tp,Card.IsReleasable,2,false,nil,nil)
	end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsReleasable,2,2,false,nil,nil)
	Duel.Release(g,REASON_COST)
end

function s.bpop(e,tp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end

	local atk=0
	for tc in g:Iter() do
		atk=atk+math.max(tc:GetAttack(),0)
	end

	if Duel.Destroy(g,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end

-- Tributes for Ra
function s.tributecost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,1,e:GetHandler()) end
    local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,99,e:GetHandler())
    e:SetLabel(g:GetSum(Card.GetAttack))
    Duel.Release(g,REASON_COST)
end
function s.tributeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local val=e:GetLabel()
    if not c:IsRelateToEffect(e) or val<=0 then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(val)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)
end