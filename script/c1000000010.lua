--Polar God Sacred Emperor Odin
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),2,99)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	--spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	--Influence of Rune
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)

	local eBan=Effect.CreateEffect(c)
	eBan:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	eBan:SetCode(EVENT_REMOVE)
	eBan:SetOperation(s.regop)
	c:RegisterEffect(eBan)

-- Special Summon al final de turno desde Cementerio
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67098114,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

-- Special Summon al final de turno desde Zona Removida (si quieres que funcione ahí también)
	local eban1=Effect.CreateEffect(c)
	eban1:SetDescription(aux.Stringid(67098114,1))
	eban1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	eban1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	eban1:SetCode(EVENT_PHASE+PHASE_END)
	eban1:SetRange(LOCATION_REMOVED)
	eban1:SetCountLimit(1)
	eban1:SetCondition(s.spcon)
	eban1:SetTarget(s.sptg)
	eban1:SetOperation(s.spop)
	c:RegisterEffect(eban1)
	--damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(93483212,2))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.drcon)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
	--cannot be tribute by your opponent
	local e21=Effect.CreateEffect(c)
	e21:SetType(EFFECT_TYPE_SINGLE)
	e21:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e21:SetRange(LOCATION_MZONE)
	e21:SetCode(EFFECT_UNRELEASABLE_SUM)
	e21:SetValue(s.sumlimit)
	c:RegisterEffect(e21)
	local e22=Effect.CreateEffect(c)
	e22:SetType(EFFECT_TYPE_FIELD)
	e22:SetCode(EFFECT_CANNOT_RELEASE)
	e22:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e22:SetRange(LOCATION_MZONE)
	e22:SetTargetRange(0,1)
	e22:SetTarget(s.relval)
	e22:SetValue(1)
	c:RegisterEffect(e22)
	--Control of this card cannot switch
	local e23=Effect.CreateEffect(c)
	e23:SetType(EFFECT_TYPE_SINGLE)
	e23:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e23:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e23:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e23)
	--Effect immunity
	local e24=e23:Clone()
	e24:SetCode(EFFECT_IMMUNE_EFFECT)
	e24:SetValue(s.efilter)
	c:RegisterEffect(e24)
	local e25=e24:Clone()
	e25:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e25:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_RITUAL,SUMMON_TYPE_XYZ,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK))
	c:RegisterEffect(e25)
		-- Cannot be returned to the hand
	local e27=Effect.CreateEffect(c)
	e27:SetType(EFFECT_TYPE_SINGLE)
	e27:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e27:SetRange(LOCATION_MZONE)
	e27:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e27)

-- Cannot be returned to the Deck
	local e28=e27:Clone()
	e28:SetCode(EFFECT_CANNOT_TO_DECK)
	c:RegisterEffect(e28)
	
end
---------------------------------------------------------
	--Influence of Rune
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(511000263)==0
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		e1:SetCondition(s.imcon)
		e1:SetOperation(s.imop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC_G)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(511000263,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_DIVINE)
end
function s.imcon(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_MONSTER) or not Duel.IsChainDisablable(ev) then return false end
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		if g and g:IsExists(s.cfilter,1,nil) then return true end
	end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TODECK)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_RELEASE)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_CONTROL)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DISABLE)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	return false
end
function s.imop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(799183,0)) then
		Duel.NegateEffect(ev)
	end
end
	--special summon
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsPreviousControler(tp) then return end
	if not c:IsPreviousLocation(LOCATION_ONFIELD) then return end
	
	if bit.band(r,REASON_BATTLE)~=0 or bit.band(r,REASON_EFFECT)~=0 or bit.band(r,REASON_DESTROY)~=0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end



function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end

-- Target para special summon
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Operación para special summon
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
	end
end
	--damage
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.tgg(c,card)
	return c:GetCardTarget() and c:GetCardTarget():IsContains(card) and not c:IsDisabled()
end
function s.disfilter(c)
	local eqg=c:GetEquipGroup():Filter(s.dischk,nil)
	local tgg=Duel.GetMatchingGroup(s.tgg,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,c)
	eqg:Merge(tgg)
	return c:IsRace(RACE_DIVINE) and #eqg>0
end
function s.dischk(c)
	return not c:IsDisabled()
end
function s.discon(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp,c,og)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local sg=Group.CreateGroup()
	local tc=g:GetFirst()
	while tc do
		local eqg=tc:GetEquipGroup():Filter(s.dischk,nil)
		local tgg=Duel.GetMatchingGroup(s.tgg,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tc)
		sg:Merge(eqg)
		sg:Merge(tgg)
		tc=g:GetNext()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local dg=sg:Select(tp,1,99,nil)
	local dc=dg:GetFirst()
	while dc do
		Duel.NegateRelatedChain(dc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		dc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		dc:RegisterEffect(e2)
		if dc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dc:RegisterEffect(e3)
		end
		dc=dg:GetNext()
	end
	Duel.BreakEffect()
	return
end
--cannot be tribute by your opponent
function s.sumlimit(e,c)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer())
end
function s.relval(e,c)
	return c==e:GetHandler()
end
--unaffected by monster effects except gods
function s.leaveChk(c,category)
	local ex,tg=Duel.GetOperationInfo(0,category)
	return ex and tg~=nil and tg:IsContains(c)
end
function s.efilter(e,te,c)
	local tc=te:GetOwner()
		return (te:IsActiveType(TYPE_MONSTER) and c~=tc) and not tc:IsOriginalAttribute(ATTRIBUTE_DIVINE)
	end