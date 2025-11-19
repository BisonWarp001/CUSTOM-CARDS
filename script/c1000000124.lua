--Hyper GOD Energy
local s,id=GetID()
s.listed_names = {10000000,10000010,10000020}
local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE

function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    c:RegisterEffect(e1)

    --Slifer: discard 1; negate; opponent monsters lose 1000 permanently
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e2:SetCondition(s.slcond)
    e2:SetCost(s.slcost)
    e2:SetTarget(s.sltg)
    e2:SetOperation(s.slop)
    c:RegisterEffect(e2)

	--Obelisk: Tribute up to 2 OTHER monsters; negate; burn 2000 per Tribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	e3:SetCondition(s.obcond)
	e3:SetCost(s.obcost)
	e3:SetTarget(s.obtg)
	e3:SetOperation(s.obop)
	c:RegisterEffect(e3)


	--Ra effect: pay 1000 LP; negate; if negated -> target 1 monster you control; it gains 1000 ATK/DEF
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	e4:SetCondition(s.racond)
	e4:SetCost(s.racost)
	e4:SetOperation(s.raop)
	c:RegisterEffect(e4)
end

-------------------------------------
-- SLIFER
-------------------------------------
-----------------------------
-- SLIFER EFFECT
-----------------------------

-- Condition: Opponent activates something, you control Slifer, and you can discard 1 card
function s.slcond(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp 
		and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(function(c)
			return c:IsFaceup() and c:IsCode(10000020)
		end,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsPlayerCanDiscardDeck(tp,1) -- You must be able to discard 1 from hand
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
end

-- COST: Discard 1 card
function s.slcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- Target: Just negate
function s.sltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

-- Operation: Negate → THEN apply -1000 ATK/DEF to all opponent monsters
function s.slop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		-- Successfully negated → apply debuff
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		for tc in g:Iter() do
			-- ATK -1000
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)

			-- DEF -1000
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end


-------------------------------------
-- OBELISK
-------------------------------------
-----------------------------
-- OBELISK EFFECT
-----------------------------

-- Condition: Opponent activates something AND you control Obelisk AND you can tribute at least 1 other monster
function s.obcond(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp 
		and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(function(c)
			return c:IsFaceup() and c:IsCode(10000000)
		end,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(function(c)
			return c:IsReleasable() and not c:IsCode(10000000)
		end,tp,LOCATION_MZONE,0,1,nil) -- must be able to tribute at least 1
end

-- COST: Tribute 1 or 2 OTHER monsters (cannot tribute Obelisk)
function s.obcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(function(c)
			return c:IsReleasable() and not c:IsCode(10000000)
		end,tp,LOCATION_MZONE,0,1,nil)
	end

	-- Select **1 or 2** monsters (no 0 allowed)
	local g=Duel.GetMatchingGroup(function(c)
		return c:IsReleasable() and not c:IsCode(10000000)
	end,tp,LOCATION_MZONE,0,nil)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tg=g:Select(tp,1,2,nil) -- FORCE minimum 1

	local ct=Duel.Release(tg,REASON_COST)
	e:SetLabel(ct) -- store HOW MANY tributes were used
end

-- Target: Always negates
function s.obtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end

-- Operation: Negate + burn 2000 per tribute
function s.obop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if Duel.NegateActivation(ev) and ct>0 then
		Duel.Damage(1-tp,ct*2000,REASON_EFFECT)
	end
end



-------------------------------------
-- RA
-------------------------------------
function s.racond(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev)
        and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,10000010)
end

function s.racost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end

function s.raop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- Primero negar
    if not Duel.NegateActivation(ev) then return end
    Duel.Hint(HINT_CARD,0,id)

    -- Ahora sí: elegimos el monstruo DESPUÉS de negar
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end

    -- Aumentar ATK/DEF permanente
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(1000)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    tc:RegisterEffect(e2)
end