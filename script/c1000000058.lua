-- Orichalcos Wave of Destruction
local s,id=GetID()

function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-------------------------------------------------
-- Activate: start tracking for the turn
-------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Prevent double activation same turn
	if Duel.GetFlagEffect(tp,id)~=0 then return end

	-- Create the flag with label = 0
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,0)

	-- Track destroyed Orichalcos cards
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetOperation(s.addcount)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- End Phase effect to destroy opponent's cards
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetOperation(s.desop)
	Duel.RegisterEffect(e2,tp)

end

-------------------------------------------------
-- Count Orichalcos destroyed by opponent
-------------------------------------------------
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp)
		and c:IsSetCard(0x3e8)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT)
		and c:GetReasonPlayer()~=tp
end

function s.addcount(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.cfilter,nil,tp)
	if ct>0 then
		local val=Duel.GetFlagEffectLabel(tp,id)
		Duel.SetFlagEffectLabel(tp,id,val+ct)
	end
end

-------------------------------------------------
-- End Phase: destroy opponent cards
-------------------------------------------------
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffectLabel(tp,id)
	if ct<=0 then return end

	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,math.min(ct,#g),math.min(ct,#g),nil)
	Duel.Destroy(sg,REASON_EFFECT)

	-- LIMPIAR FLAG para que no vuelva a intentar activarse
	Duel.ResetFlagEffect(tp,id)
end

