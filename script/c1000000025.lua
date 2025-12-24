--My Name is Atem
local s,id=GetID()

-- Código de Divine Hierachy
local HIERARCHY = 1000000013

function s.initial_effect(c)

    -----------------------------------------------------
    -- Esta carta NO puede ser Invocada Especial
    -----------------------------------------------------
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.FALSE)
    c:RegisterEffect(e0)

    -----------------------------------------------------
    --Efecto 1: Tribute this card; SS 1 Divine-Beast
    -----------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost_release_self)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -----------------------------------------------------
    --Efecto 2: Banish this card; Add 1 “Divine Hierachy”
    -----------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

end

---------------------------------------------
-- COST: Tribute this card
---------------------------------------------
function s.cost_release_self(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

-- FILTRO: solo Dioses Egipcios específicos
---------------------------------------------
function s.spfilter(c,e,tp)
    return (c:IsCode(10000000,10000010,10000080,10000020))
        and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end


---------------------------------------------
-- TARGET para el Special Summon
---------------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(
            s.spfilter,tp,
            LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,
            0,1,nil,e,tp
        )
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

---------------------------------------------
-- OPERACIÓN: Special Summon + evitar auto-GY
---------------------------------------------
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,
        0,1,1,nil,e,tp)
    local sc=g:GetFirst()
    if not sc then return end

    -- SPECIAL SUMMON IGNORING CONDITIONS
    if Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)>0 then
        
        -----------------------------------------------------
        -- Evitar que Ra / Wicked se auto-envíen al GY
        -----------------------------------------------------
        local e1=Effect.CreateEffect(sc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_TO_GRAVE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        sc:RegisterEffect(e1)

        local e2=e1:Clone()
        e2:SetCode(EFFECT_CANNOT_REMOVE)
        sc:RegisterEffect(e2)

        local e3=e1:Clone()
        e3:SetCode(EFFECT_CANNOT_TO_DECK)
        sc:RegisterEffect(e3)
    end
end

---------------------------------------------
-- COST del segundo efecto: banish this card
---------------------------------------------
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end
    aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
end

---------------------------------------------
-- Target: buscar Divine Hierachy
---------------------------------------------
function s.thfilter(c)
    return c:IsCode(HIERARCHY) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.thfilter,tp,
            LOCATION_DECK+LOCATION_GRAVE,
            0,1,nil
        )
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,
        LOCATION_DECK+LOCATION_GRAVE)
end

---------------------------------------------
-- Operación: añadir Divine Hierachy
---------------------------------------------
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,
        LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
