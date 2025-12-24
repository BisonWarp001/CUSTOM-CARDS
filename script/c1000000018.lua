--Egyptian God Eternal Slime - Devourer (Xyz)
local s,id=GetID()

function s.initial_effect(c)
    ---------------------------------------------
    -- Xyz Summon (2+ Level 10 monsters)
    ---------------------------------------------
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsLevel,10),10,2,nil,nil,nil,nil,false)

    ---------------------------------------------
    -- Cannot be destroyed by battle
    ---------------------------------------------
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(1)
    c:RegisterEffect(e0)

    ---------------------------------------------
    -- Opponent cannot target other monsters
    ---------------------------------------------
    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_FIELD)
    e0b:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e0b:SetRange(LOCATION_MZONE)
    e0b:SetTargetRange(LOCATION_MZONE,0)
    e0b:SetTarget(s.protecttg)
    e0b:SetValue(aux.imval1)
    c:RegisterEffect(e0b)

    local e0c=Effect.CreateEffect(c)
    e0c:SetType(EFFECT_TYPE_FIELD)
    e0c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e0c:SetRange(LOCATION_MZONE)
    e0c:SetTargetRange(LOCATION_MZONE,0)
    e0c:SetTarget(s.protecttg)
    e0c:SetValue(aux.tgoval)
    c:RegisterEffect(e0c)

    ---------------------------------------------
    -- Quick: Negate & attach
    ---------------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_LEAVE_GRAVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)

    ---------------------------------------------
    -- If sent to GY: Special Summon 1 Level 10 WATER (not itself)
    ---------------------------------------------
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCondition(s.spcon_gy)
    e4:SetTarget(s.sptg_gy)
    e4:SetOperation(s.spop_gy)
    c:RegisterEffect(e4)
end

---------------------------------------------------------
-- Protection target filter
---------------------------------------------------------
function s.protecttg(e,c)
    return c~=e:GetHandler()
end

---------------------------------------------------------
-- Negate + attach
---------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and Duel.IsChainNegatable(ev)
        and re:IsActiveType(TYPE_MONSTER) -- monster effect
        or (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
        and re:GetHandler():IsAbleToRemove()) -- Spell/Trap that SS
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=re:GetHandler()
    if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
        Duel.Overlay(c,Group.FromCards(rc))
    end
end

---------------------------------------------------------
-- Sent to GY → Special Summon Level 10 WATER
---------------------------------------------------------
function s.spcon_gy(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end

function s.spfilter_gy(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsLevel(10)
        and not c:IsCode(id)  -- prevents self-summon
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg_gy(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter_gy,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop_gy(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter_gy,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
