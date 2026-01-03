--Avatar Judgment
local s,id=GetID()

function s.initial_effect(c)
	--Activate (Quick-Play Spell)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.actcon)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Must control The Wicked Avatar
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(
		function(c) return c:IsFaceup() and c:IsCode(21208154) end,
		tp,LOCATION_MZONE,0,1,nil
	)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local avatar=Duel.GetFirstMatchingCard(
		function(c) return c:IsFaceup() and c:IsCode(21208154) end,
		tp,LOCATION_MZONE,0,nil
	)
	if not avatar then return end

	local atk=avatar:GetAttack()

	-- Negate effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.negfilter(atk))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	Duel.RegisterEffect(e2,tp)

	-- Cannot be used as material for Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.negfilter(atk))
	e3:SetValue(1)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	-- Destroy during End Phase
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetCondition(function() return Duel.GetTurnPlayer()==tp end)
	e4:SetOperation(s.desop(atk))
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)
end

function s.negfilter(atk)
	return function(e,c)
		return c:IsFaceup() and c:GetAttack()<atk
	end
end

function s.desop(atk)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(
			function(c)
				return c:IsFaceup() and c:IsControler(1-tp) and c:GetAttack()<atk
			end,
			tp,0,LOCATION_MZONE,nil
		)
		if #g==0 then return end
		if Duel.Destroy(g,REASON_EFFECT)==0 then return end

		-- Save codes
		local codes={}
		for tc in aux.Next(g) do
			local c1,c2=tc:GetOriginalCodeRule()
			codes[c1]=true
			if c2 then codes[c2]=true end
		end

		-- Negate GY activated effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(function(_,tp,_,_,ev,re)
			if not re:IsMonsterEffect() then return false end
			local rc=re:GetHandler()
			if not rc:IsLocation(LOCATION_GRAVE) then return false end
			local c1,c2=rc:GetOriginalCodeRule()
			return codes[c1] or (c2 and codes[c2])
		end)
		e1:SetOperation(function(_,tp,_,_,ev)
			Duel.NegateEffect(ev)
		end)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		Duel.RegisterEffect(e1,tp)
	end
end
