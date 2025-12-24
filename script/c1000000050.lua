--Orichalcos Aristeros 


local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	-------------------------------------------------
	-- Cannot be Normal Summoned / Set
	-------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e0)
	local e0b=e0:Clone()
	e0b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e0b)

	-------------------------------------------------
	-- Special Summon from hand if you control Shunoros
	-------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	-------------------------------------------------
	-- Redirect attack + gain DEF (ATK + 300)
	-------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.cbcon)
	e2:SetOperation(s.cbop)
	c:RegisterEffect(e2)

	-------------------------------------------------
	-- Negate Trap (Quick Effect)
	-------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)

	-------------------------------------------------
	-- Destroy if King Shunoros leaves the field
	-------------------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end

s.listed_names={1000000050}

-------------------------------------------------
-- Shunoros filter
-------------------------------------------------
function s.shunfilter(c)
	return c:IsFaceup() and c:IsCode(1000000050)
end

-------------------------------------------------
-- Special Summon condition from hand
-------------------------------------------------
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.shunfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end

-------------------------------------------------
-- Redirect attack condition
-------------------------------------------------
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local bt=eg:GetFirst()
	return bt~=e:GetHandler() and bt:IsControler(tp)
end

-------------------------------------------------
-- Redirect attack + DEF = ATK + 300 (Damage Step)
-------------------------------------------------
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=Duel.GetAttacker()
	if not atk or atk:IsImmuneToEffect(e) then return end
	if Duel.ChangeAttackTarget(c) then
		local def=atk:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end

-------------------------------------------------
-- Trap negate condition
-------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

-------------------------------------------------
-- Destroy if Shunoros leaves the field
-------------------------------------------------
function s.desfilter(c,tp)
	return c:IsCode(1000000050)
		and c:IsPreviousPosition(POS_FACEUP)
		and c:GetPreviousControler()==tp
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,nil,tp)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
